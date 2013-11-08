require 'spec_helper'

describe 'cf-jenkins::jenkins' do
  subject(:chef_run) { ChefSpec::Runner.new.converge(described_recipe, 'cf-jenkins::_test_stubs') }

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

  it 'works around debian package bug in jenkins release 1.538' do
    expect(chef_run).to create_directory('/var/run/jenkins')
  end
  it 'sets jenkins user shell to /bin/bash' do
    expect(chef_run).to modify_user('jenkins').with(shell: '/bin/bash')
  end
  it { expect(chef_run).to include_recipe('selfsigned_certificate') }
  it { expect(chef_run).to include_recipe('cf-jenkins::aws') }
  it { expect(chef_run).to include_recipe('jenkins::server') }
  it { expect(chef_run).to include_recipe('jenkins::proxy') }
  it { expect(chef_run).to include_recipe('cf-jenkins::plugins') }
  it { expect(chef_run).to include_recipe('cf-jenkins::jobs') }
end
