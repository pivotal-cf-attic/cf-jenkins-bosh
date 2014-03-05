require 'spec_helper'

describe 'cf-jenkins::node' do
  subject(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before { stub_include_recipe_calls }

  it { expect(chef_run).to include_recipe('apt') }
  it { expect(chef_run).to include_recipe('chef_rubies') }
  it { expect(chef_run).to include_recipe('cf-jenkins::gvm') }
  it { expect(chef_run).to include_recipe('cf-jenkins::packages') }
end
