require 'spec_helper'

describe 'cf-jenkins::disable_nginx_default_site' do
  subject(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'disables to default nginx site (which clashes with the jenkins nginx site)' do
    expect(chef_run.node['nginx']['default_site_enabled']).to eq(false)
  end
end
