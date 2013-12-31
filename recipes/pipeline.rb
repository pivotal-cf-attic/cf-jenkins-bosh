# Pipeline steps need user-specified versions of Ruby
include_recipe 'chef_rubies'

# Pipeline steps need Go available
include_recipe 'cf-jenkins::gvm'

# Minimal recipes to get Jenkins running
include_recipe 'cf-jenkins::jenkins_base'

# Able to specify pipelines by supplying Git, etc. info
include_recipe 'cf-jenkins::pipelines'

# Install only the plugins needed for pipeline steps
include_recipe 'cf-jenkins::pipeline_jenkins_plugins'

include_recipe 'cf-jenkins::pipeline_auth'
