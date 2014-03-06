node.default['cf_jenkins']['plugins'] = %w(
  git
  git-client
  github
  multiple-scms
  github-api
  ssh-credentials
  ssh-agent
  credentials
  git-parameter
  subversion
  promoted-builds
  conditional-buildstep
  maven-plugin
  javadoc
  mailer
  scm-api
  token-macro
  parameterized-trigger
  run-condition
  build-timeout
  ansicolor
  greenballs
  buildgraph-view
  build-flow-plugin
  iphoneview
)

node.default['cf_jenkins']['pipelines'] = []

include_recipe 'cf-jenkins::node'
include_recipe 'cf-jenkins::jenkins'

user node['jenkins']['server']['user'] do
  shell '/bin/bash'
  action :modify
end

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
