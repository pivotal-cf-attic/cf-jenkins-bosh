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

include_recipe 'apt'

include_recipe 'chef_rubies'

include_recipe 'cf-jenkins::gvm'
include_recipe 'cf-jenkins::packages'
include_recipe 'cf-jenkins::jenkins'
include_recipe 'cf-jenkins::ssh_config'
