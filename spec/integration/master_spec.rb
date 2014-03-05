require 'spec_helper'

describe 'master', type: :integration do
  it 'can run a Jenkins job which requires gvm, go1.2, chruby, and ruby 1.9.3' do
    client = JenkinsApi::Client.new(server_ip: '192.168.33.10')

    expect(client).to successfully_build('dummy_job')
  end
end
