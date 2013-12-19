node['cf_jenkins']['pipelines'].each do |name, pipeline_settings|
  deploy_job_dir = ::File.join(node['jenkins']['server']['home'], 'jobs', "#{name}-deploy")
  deploy_job_config = ::File.join(deploy_job_dir, 'config.xml')

  directory deploy_job_dir do
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00755
    action :create
  end

  file deploy_job_config do
    job = JenkinsClient::Job.new
    job.git_repo_url = pipeline_settings.fetch('git')
    job.git_repo_branch = pipeline_settings.fetch('release_ref')
    job.downstream_jobs = ["#{name}-system_tests"]

    options = %W(
      --non-interactive
      --release-name #{name}
      --release-repo #{pipeline_settings.fetch('git')}
      --release-ref #{pipeline_settings.fetch('release_ref')}
      --infrastructure #{pipeline_settings.fetch('infrastructure')}
      --deployments-repo #{pipeline_settings.fetch('deployments_repo')}
      --deployment-name #{pipeline_settings.fetch('deployment_name')}
      --rebase
    ).join(' ')
    job.command = <<-BASH
#!/bin/bash
set -x

source /usr/local/share/chruby/chruby.sh
chruby 1.9.3
gem install bundler --no-ri --no-rdoc --conservative
bundle install

source /usr/local/share/gvm/scripts/gvm
gvm use go1.2

SHELL=/bin/bash bundle exec cf_deploy #{options}
    BASH
    content job.to_xml

    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00644
  end

  jenkins_job "#{name}-deploy" do
    config deploy_job_config
    action :update
  end

  tests_job_dir = ::File.join(node['jenkins']['server']['home'], 'jobs', "#{name}-system_tests")
  tests_job_config = ::File.join(tests_job_dir, 'config.xml')

  directory tests_job_dir do
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00755
    action :create
  end

  file tests_job_config do
    job = JenkinsClient::Job.new
    job.git_repo_url = pipeline_settings.fetch('git')
    job.git_repo_branch = pipeline_settings.fetch('release_ref')

    options = %W(
      --non-interactive
      --release-name #{name}
      --release-repo #{pipeline_settings.fetch('git')}
      --release-ref #{pipeline_settings.fetch('release_ref')}
      --infrastructure #{pipeline_settings.fetch('infrastructure')}
      --deployments-repo #{pipeline_settings.fetch('deployments_repo')}
      --deployment-name #{pipeline_settings.fetch('deployment_name')}
      --rebase
    ).join(' ')
    job.command = <<-BASH
#!/bin/bash
set -x

source /usr/local/share/chruby/chruby.sh
chruby 1.9.3
gem install bundler --no-ri --no-rdoc --conservative
bundle install

source /usr/local/share/gvm/scripts/gvm
gvm use go1.2

script/run_system_tests
    BASH
    content job.to_xml

    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00644
  end

  jenkins_job "#{name}-system_tests" do
    config tests_job_config
    action :update
  end
end
