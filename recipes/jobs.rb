service 'jenkins' do
  action :restart
  notifies :create, 'ruby_block[block_until_operational]', :immediately
end

node['cf_jenkins']['jobs'].each do |job_settings|
  job_dir = ::File.join(node['jenkins']['server']['home'], 'jobs', job_settings[:name])
  job_config = ::File.join(job_dir, 'config.xml')

  directory job_dir do
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00755
    action :create
  end

  jenkins_job job_settings[:name] do
    config job_config
    action :nothing
  end

  template job_config do
    if job_settings[:build_flow]
      source 'build-flow-config.xml.erb'
    else
      source 'config.xml.erb'
    end

    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00644
    variables job_settings[:build_vars]
    notifies(:update, resources("jenkins_job[#{job_settings[:name]}]"), :immediately)
  end
end
