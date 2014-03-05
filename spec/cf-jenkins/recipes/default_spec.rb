require 'spec_helper'

describe 'cf-jenkins::default' do
  subject(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['jenkins']['server']['home'] = '/jenkins/server/home'
      node.set['jenkins']['server']['user'] = 'jenkins'
      node.set['cf_jenkins']['ssh_key'] = 'the_private_key'
      node.set['cf_jenkins']['ssh_key_pub'] = 'the_public_key'
      node.set['cf_jenkins']['ssh_known_hosts'] = ['host1', 'host2']
    end.converge(described_recipe)
  end

  before { stub_include_recipe_calls }

  it { expect(chef_run).to include_recipe('cf-jenkins::node') }
  it { expect(chef_run).to include_recipe('cf-jenkins::jenkins') }

  it 'sets default plugins' do
    plugins = chef_run.node['cf_jenkins']['plugins']

    # Probably not necessary to assert every default plugin, just that it sets something.
    expect(plugins).to include('git')
    expect(plugins).to include('greenballs')
  end

  it 'sets jenkins user shell to /bin/bash' do
    expect(chef_run).to modify_user('jenkins').with(shell: '/bin/bash')
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
