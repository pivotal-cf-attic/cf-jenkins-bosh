include_recipe 'cf-jenkins::node'

group node['jenkins']['node']['user']

directory node['jenkins']['node']['home'] do
  owner node['jenkins']['node']['user']
  group node['jenkins']['node']['group']
  action :create
end

user node['jenkins']['node']['user'] do
  shell '/bin/bash'
  gid node['jenkins']['node']['user']
  action :create
  home node['jenkins']['node']['home']
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

file ::File.join(node['jenkins']['node']['home'], '.ssh', 'authorized_keys') do
  user node['jenkins']['node']['user']
  group node['jenkins']['node']['user']
  content node['cf_jenkins']['ssh_authorized_keys'].join("\n")
end

package 'redis-server'

directory node['jenkins']['server']['home'] do
  owner node['jenkins']['node']['user']
  group node['jenkins']['node']['user']
  mode 0700
end
