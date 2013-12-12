require 'spec_helper'

describe 'cf-jenkins::default' do
  subject(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before { stub_include_recipe_calls }

  it { expect(chef_run).to include_recipe('apt') }
  it { expect(chef_run).to include_recipe('chef_rubies') }
  it { expect(chef_run).to include_recipe('cf-jenkins::jenkins') }
  it { expect(chef_run).to include_recipe('cf-jenkins::gvm') }
  it { expect(chef_run).to include_recipe('cf-jenkins::ssh_config') }
  it { expect(chef_run).to include_recipe('cf-jenkins::packages') }

  it 'sets default plugins' do
    plugins = chef_run.node['cf_jenkins']['plugins']

    # Probably not necessary to assert every default plugin, just that it sets something.
    expect(plugins).to include('git')
    expect(plugins).to include('greenballs')
  end
end
