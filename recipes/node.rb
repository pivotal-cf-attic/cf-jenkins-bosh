include_recipe 'apt'

include_recipe 'rubies'

include_recipe 'cf-jenkins::gvm'
include_recipe 'cf-jenkins::packages'
