chef_gem 'nokogiri'

def add_jenkins_job_for_step(pipeline_name, pipeline_settings, step, next_step, command)
  job_dir = ::File.join(node['jenkins']['server']['home'], 'jobs', "#{pipeline_name}-#{step}")
  job_config = ::File.join(job_dir, 'config.xml')

  directory job_dir do
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00755
    action :create
  end

  file job_config do
    job = JenkinsClient::Job.new
    job.git_repo_url = pipeline_settings.fetch('git')
    job.git_repo_branch = pipeline_settings.fetch('release_ref')
    job.downstream_jobs = ["#{pipeline_name}-#{next_step}"] if next_step
    job.command = <<-CMD
#!/bin/bash
set -x

source /usr/local/share/chruby/chruby.sh
chruby 1.9.3
gem install bundler --no-ri --no-rdoc --conservative
bundle install

source /usr/local/share/gvm/scripts/gvm
gvm use go1.2

#{command}
    CMD

    content job.to_xml

    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00644
  end

  jenkins_job "#{pipeline_name}-#{step}" do
    config job_config
    action :update
  end
end

node['cf_jenkins']['pipelines'].each do |name, pipeline_settings|
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

  add_jenkins_job_for_step(name, pipeline_settings, 'deploy', 'system_tests',
                           "SHELL=/bin/bash bundle exec cf_deploy #{options}")
  add_jenkins_job_for_step(name, pipeline_settings, 'system_tests', 'release_tarball',
                           "script/run_system_tests")
  add_jenkins_job_for_step(name, pipeline_settings, 'release_tarball', nil,
                           "echo #{name} | bosh create release --with-tarball --force")
end
