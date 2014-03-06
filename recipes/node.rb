include_recipe 'apt'

include_recipe 'chef_rubies'

include_recipe 'cf-jenkins::gvm'
include_recipe 'cf-jenkins::packages'
