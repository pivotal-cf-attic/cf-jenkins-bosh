node['cf_jenkins']['plugins'].each do |plugin|
  jenkins_plugin plugin do
    action :install
  end
end
