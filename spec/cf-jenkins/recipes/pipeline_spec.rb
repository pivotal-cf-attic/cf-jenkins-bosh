require 'spec_helper'

describe 'cf-jenkins::pipeline' do
  subject(:chef_run) { ChefSpec::Runner.new.converge(described_recipe, 'cf-jenkins::_test_stubs') }

  before { stub_include_recipe_calls }

  it { expect(chef_run).to include_recipe('chef_rubies') }
  it { expect(chef_run).to include_recipe('cf-jenkins::gvm') }
  it { expect(chef_run).to include_recipe('cf-jenkins::jenkins_base') }
  it { expect(chef_run).to include_recipe('cf-jenkins::pipelines') }
  it { expect(chef_run).to include_recipe('cf-jenkins::pipeline_jenkins_plugins') }
  it { expect(chef_run).to include_recipe('cf-jenkins::disable_nginx_default_site') }
end
