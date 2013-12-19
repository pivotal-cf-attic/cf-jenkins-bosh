node['cf_jenkins']['pipelines'].each do |name, pipeline_settings|
  deploy_job_dir = ::File.join(node['jenkins']['server']['home'], 'jobs', "#{name}-deploy")
  deploy_job_config = ::File.join(deploy_job_dir, 'config.xml')

  directory deploy_job_dir do
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00755
    action :create
  end

  template deploy_job_config do
    source 'pipeline_deploy_config.xml.erb'
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00644
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
    command = <<-BASH
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
    variables(
      'shell_command' => command,
      'repo' => pipeline_settings.fetch('git'),
      'repo_branch' => pipeline_settings.fetch('release_ref'),
      'downstream_project' => "#{name}-system_tests"
    )
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

  template tests_job_config do
    source 'pipeline_system_tests_config.xml.erb'
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00644
    command = <<-BASH
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
    variables(
      'shell_command' => command,
      'repo' => pipeline_settings.fetch('git'),
      'repo_branch' => pipeline_settings.fetch('release_ref')
    )
  end

  jenkins_job "#{name}-system_tests" do
    config tests_job_config
    action :update
  end
end
