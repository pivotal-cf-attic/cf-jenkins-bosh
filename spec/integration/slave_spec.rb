require 'spec_helper'

describe 'slave', type: :integration do
  it 'can run a Jenkins job which requires gvm, go1.2, chruby, and ruby 1.9.3' do
    client = JenkinsApi::Client.new(server_ip: '192.168.33.10')
    client.job.restrict_to_node('slave_job', 'jenkins-slave')

    expect(client).to successfully_build('slave_job').on_node('jenkins-slave')
  end
end
