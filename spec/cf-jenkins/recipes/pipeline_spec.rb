require 'spec_helper'

describe 'cf-jenkins::pipeline' do
  subject(:chef_run) { ChefSpec::Runner.new.converge(described_recipe, 'cf-jenkins::_test_stubs') }

  before { stub_include_recipe_calls }

  example { expect(chef_run).to include_recipe('chef_rubies') }
  example { expect(chef_run).to include_recipe('cf-jenkins::gvm') }
  example { expect(chef_run).to include_recipe('cf-jenkins::jenkins_base') }
  example { expect(chef_run).to include_recipe('cf-jenkins::pipelines') }
  example { expect(chef_run).to include_recipe('cf-jenkins::pipeline_jenkins_plugins') }
  example { expect(chef_run).to include_recipe('cf-jenkins::pipeline_auth') }
end
