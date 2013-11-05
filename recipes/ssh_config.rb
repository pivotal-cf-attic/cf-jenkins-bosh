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

file ::File.join(node['jenkins']['server']['home'], '.ssh', 'known_hosts') do
  user node['jenkins']['server']['user']
  group node['jenkins']['server']['user']
  content node['cf_jenkins']['ssh_known_hosts'].join("\n")
end
