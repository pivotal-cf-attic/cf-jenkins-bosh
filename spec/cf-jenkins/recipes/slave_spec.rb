require 'spec_helper'

describe 'cf-jenkins::slave' do
  subject(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['jenkins']['node']['home'] = '/jenkins/node/home'
      node.set['jenkins']['node']['user'] = 'jenkins-node'
      node.set['jenkins']['node']['shell'] = '/bin/bash'
      node.set['jenkins']['server']['home'] = '/path/to/server/home'
      node.set['cf_jenkins']['ssh_key'] = 'the_private_key'
      node.set['cf_jenkins']['ssh_key_pub'] = 'the_public_key'
      node.set['cf_jenkins']['ssh_known_hosts'] = ['host1', 'host2']
      node.set['cf_jenkins']['ssh_authorized_keys'] = ['key1', 'key2']
    end.converge(described_recipe)
  end

  before { stub_include_recipe_calls }

  it { expect(chef_run).to include_recipe('cf-jenkins::node') }

  it 'creates jenkins home directory' do
    expect(chef_run).to create_directory('/jenkins/node/home').with(owner: 'jenkins-node')
  end

  it 'sets jenkins user shell to /bin/bash and sets its home directory' do
    expect(chef_run).to create_user('jenkins-node').with(shell: '/bin/bash', home: '/jenkins/node/home')
  end

  it 'makes the .ssh directory' do
    expect(chef_run).to create_directory('/jenkins/node/home/.ssh')
  end

  it 'sets the private SSH key to the given content' do
    expect(chef_run).to render_file('/jenkins/node/home/.ssh/id_rsa').with_content('the_private_key')
  end

  it 'sets the public SSH key to the given content' do
    expect(chef_run).to render_file('/jenkins/node/home/.ssh/id_rsa.pub').with_content('the_public_key')
  end

  it 'populates the known_hosts file' do
    expect(chef_run).to render_file('/jenkins/node/home/.ssh/known_hosts').with_content("host1\nhost2")
  end

  it 'populates the authorized_keys file' do
    expect(chef_run).to render_file('/jenkins/node/home/.ssh/authorized_keys').with_content("key1\nkey2")
  end

  it { should install_package('redis-server') }

  it 'makes the server home directory' do
    expect(chef_run).to create_directory('/path/to/server/home')
  end
end
