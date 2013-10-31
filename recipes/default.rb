include_recipe 'apt'

include_recipe 'chef_rubies'

include_recipe 'selfsigned_certificate'

include_recipe 'jenkins::server'
include_recipe 'jenkins::proxy'

include_recipe 'cf-jenkins::gvm'
include_recipe 'cf-jenkins::ssh_config'
include_recipe 'cf-jenkins::packages'
include_recipe 'cf-jenkins::jobs'