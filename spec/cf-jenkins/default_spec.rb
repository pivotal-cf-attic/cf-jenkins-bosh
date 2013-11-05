require 'spec_helper'

describe 'cf-jenkins::default' do
  subject(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before do
    Chef::Cookbook::Metadata.any_instance.stub(:depends) # ignore external cookbook dependencies

    # Test each recipe in isolation, regardless of includes
    @included_recipes = []
    Chef::RunContext.any_instance.stub(:loaded_recipe?).and_return(false)
    Chef::Recipe.any_instance.stub(:include_recipe) do |i|
      Chef::RunContext.any_instance.stub(:loaded_recipe?).with(i).and_return(true)
      @included_recipes << i
    end
    Chef::RunContext.any_instance.stub(:loaded_recipes).and_return(@included_recipes)
  end

  it { expect(chef_run).to include_recipe('apt') }
  it { expect(chef_run).to include_recipe('chef_rubies') }
  it { expect(chef_run).to include_recipe('cf-jenkins::jenkins') }
  it { expect(chef_run).to include_recipe('cf-jenkins::gvm') }
  it { expect(chef_run).to include_recipe('cf-jenkins::ssh_config') }
  it { expect(chef_run).to include_recipe('cf-jenkins::packages') }
  it { expect(chef_run).to include_recipe('cf-jenkins::jobs') }
end
