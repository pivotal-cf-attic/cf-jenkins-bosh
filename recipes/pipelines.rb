node['cf_jenkins']['pipelines'].each do |name, pipeline_settings|
  job_dir = ::File.join(node['jenkins']['server']['home'], 'jobs', "#{name}-deploy")
  job_config = ::File.join(job_dir, 'config.xml')

  directory job_dir do
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00755
    action :create
  end

  template job_config do
    source 'config.xml.erb'
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
    ).join(' ')
    command = <<-BASH
#!/bin/bash
set -x

source /usr/local/share/chruby/chruby.sh
chruby 1.9.3
gem install bundler --no-ri --no-rdoc --conservative
bundle install

SHELL=/bin/bash bundle exec cf_deploy #{options}
    BASH
    variables(
      'build_shell_command' => command,
      'build_repo' => pipeline_settings.fetch('git'),
      'build_repo_branch' => pipeline_settings.fetch('release_ref')
    )
  end

  jenkins_job "#{name}-deploy" do
    config job_config
    action :update
  end
end
