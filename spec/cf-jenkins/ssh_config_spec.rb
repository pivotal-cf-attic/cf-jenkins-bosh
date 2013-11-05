require 'spec_helper'

describe 'cf-jenkins::ssh_config' do
  subject(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['jenkins']['server']['home'] = '/jenkins/server/home'
      node.set['cf_jenkins']['ssh_key'] = 'the_private_key'
      node.set['cf_jenkins']['ssh_key_pub'] = 'the_public_key'
      node.set['cf_jenkins']['ssh_known_hosts'] = ['host1', 'host2']
    end.converge(described_recipe)
  end

  it 'makes the .ssh directory' do
    expect(chef_run).to create_directory('/jenkins/server/home/.ssh')
  end

  it 'sets the private SSH key to the given content' do
    expect(chef_run).to render_file('/jenkins/server/home/.ssh/id_rsa').with_content('the_private_key')
  end

  it 'sets the public SSH key to the given content' do
    expect(chef_run).to render_file('/jenkins/server/home/.ssh/id_rsa.pub').with_content('the_public_key')
  end

  it 'populates the known_hosts file' do
    expect(chef_run).to render_file('/jenkins/server/home/.ssh/known_hosts').with_content("host1\nhost2")
  end
end
