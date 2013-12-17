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
    variables(
      'build_shell_command' => "cf_deploy --dirty --release-name #{name} --release-repo #{pipeline_settings.fetch('git')} --release-ref #{pipeline_settings.fetch('release_ref')} --infrastructure #{pipeline_settings.fetch('infrastructure')} --deployments-repo #{pipeline_settings.fetch('deployments_repo')} --deployment-name #{pipeline_settings.fetch('deployment_name')}",
      'build_repo' => pipeline_settings.fetch('git'),
      'build_repo_branch' => pipeline_settings.fetch('release_ref')
    )
  end

  jenkins_job "#{name}-deploy" do
    config job_config
    action :update
  end
end
