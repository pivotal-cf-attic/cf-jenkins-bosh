node['cf_jenkins']['pipeline_jobs'].each do |job_settings|
  job_dir = ::File.join(node['jenkins']['server']['home'], 'jobs', job_settings[:name])
  job_config = ::File.join(job_dir, 'config.xml')
  job_template_source = 'job_dsl_config.xml.erb'

  directory job_dir do
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00755
    action :create
  end

  template job_config do
    action :create
    source job_template_source
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['user']
    mode 00644
    variables("code" => job_settings[:code])
  end

  jenkins_job job_settings[:name] do
    config job_config
    action :update
  end
end
