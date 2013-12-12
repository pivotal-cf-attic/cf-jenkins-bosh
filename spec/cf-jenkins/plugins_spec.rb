require 'spec_helper'

describe 'cf-jenkins::plugins' do
  subject(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['cf_jenkins']['plugins'] = %w(chucknorris emotional-jenkins-plugin)
    end.converge(described_recipe)
  end

  it 'installs only the plugins in cf_jenkins.plugins' do
    expect(chef_run).to install_jenkins_plugin('chucknorris')
    expect(chef_run).to install_jenkins_plugin('emotional-jenkins-plugin')
  end
end
