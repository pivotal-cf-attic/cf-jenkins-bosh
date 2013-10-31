directory ::File.join(node['jenkins']['server']['home'], '.ssh') do
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['user']
  mode 0700
end

file ::File.join(node['jenkins']['server']['home'], '.ssh', 'id_rsa') do
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['user']
  mode 0600
  content node['cf_jenkins']['ssh_key']
end

file ::File.join(node['jenkins']['server']['home'], '.ssh', 'id_rsa.pub') do
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['user']
  mode 0644
  content node['cf_jenkins']['ssh_key_pub']
end

node['cf_jenkins']['ssh_known_hosts'].each do |known_host|
  execute 'add github to known hosts if necessary' do
    known_hosts = ::File.join(node['jenkins']['server']['home'], '.ssh', 'known_hosts')
    command "echo '#{known_host}' >> #{known_hosts}"
    user node['jenkins']['server']['user']
    group node['jenkins']['server']['user']

    not_if "grep '#{known_host}' #{known_hosts}"
  end
end
