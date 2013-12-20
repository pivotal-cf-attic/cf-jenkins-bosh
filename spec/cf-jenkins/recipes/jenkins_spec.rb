require 'spec_helper'

describe 'cf-jenkins::jenkins' do
  subject(:chef_run) { ChefSpec::Runner.new.converge(described_recipe, 'cf-jenkins::_test_stubs') }

  before { stub_include_recipe_calls }

  it { expect(chef_run).to include_recipe('cf-jenkins::jenkins_base') }
  it { expect(chef_run).to include_recipe('cf-jenkins::plugins') }
  it { expect(chef_run).to include_recipe('cf-jenkins::jobs') }
end
