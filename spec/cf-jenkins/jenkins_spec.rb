require 'spec_helper'

describe 'cf-jenkins::jenkins' do
  subject(:chef_run) { ChefSpec::Runner.new.converge(described_recipe, 'cf-jenkins::_test_stubs') }

  before { stub_include_recipe_calls }

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
