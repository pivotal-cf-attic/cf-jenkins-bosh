require 'spec_helper'

describe 'cf-jenkins::pipeline_jenkins_plugins' do
  subject(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it { expect(chef_run).to install_jenkins_plugin('git') }
  it { expect(chef_run).to install_jenkins_plugin('parameterized-trigger') }
  it { expect(chef_run).to install_jenkins_plugin('ansicolor') }
end
