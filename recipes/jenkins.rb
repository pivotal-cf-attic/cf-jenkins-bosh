include_recipe 'selfsigned_certificate'

# workaround for broken debian package of current/newest version of jenkins:
# https://issues.jenkins-ci.org/browse/JENKINS-20407?page=com.atlassian.streams.streams-jira-plugin:activity-stream-issue-tab
directory '/var/run/jenkins' do
  action :create
end

include_recipe 'jenkins::server'
include_recipe 'jenkins::proxy'
