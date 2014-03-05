include_recipe 'cf-jenkins::node'
include_recipe 'jenkins::node'

user node['jenkins']['node']['user'] do
  shell '/bin/bash'
  action :modify
end

directory ::File.join(node['jenkins']['node']['home'], '.ssh') do
  owner node['jenkins']['node']['user']
  group node['jenkins']['node']['user']
  mode 0700
end

file ::File.join(node['jenkins']['node']['home'], '.ssh', 'id_rsa') do
  owner node['jenkins']['node']['user']
  group node['jenkins']['node']['user']
  mode 0600
  content node['cf_jenkins']['ssh_key']
end

file ::File.join(node['jenkins']['node']['home'], '.ssh', 'id_rsa.pub') do
  owner node['jenkins']['node']['user']
  group node['jenkins']['node']['user']
  mode 0644
  content node['cf_jenkins']['ssh_key_pub']
end

file ::File.join(node['jenkins']['node']['home'], '.ssh', 'known_hosts') do
  user node['jenkins']['node']['user']
  group node['jenkins']['node']['user']
  content node['cf_jenkins']['ssh_known_hosts'].join("\n")
end
