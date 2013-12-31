node['cf_jenkins']['jobs'].each do |job_settings|
  job_dir = ::File.join(node['jenkins']['server']['home'], 'jobs', job_settings[:name])
  job_config = ::File.join(job_dir, 'config.xml')
  job_template_source = job_settings[:build_flow] ? 'build-flow-config.xml.erb' : 'config.xml.erb'

  directory job_dir do
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00755
    action :create
  end

  build_repo = job_settings[:build_vars].fetch(:build_repo)
  build_repo_directory = job_settings[:build_vars][:build_repo_directory]
  cmd_to_fix_build_repo_remote = "git remote add -f origin #{build_repo}"
  if build_repo_directory
    cmd_to_fix_build_repo_remote = "(cd #{build_repo_directory}; #{cmd_to_fix_build_repo_remote})"
  end

  job_settings[:build_vars][:cmd_to_fix_build_repo_remote] = cmd_to_fix_build_repo_remote
  template job_config do
    source job_template_source
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00644
    variables job_settings[:build_vars]
  end

  jenkins_job job_settings[:name] do
    config job_config
    action :update
  end
end
