require 'spec_helper'

describe 'cf-jenkins::packages' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  [
    'curl',
    'htop',
    'vim',
    'libxslt-dev',
    'libxml2-dev',
    'maven',
    'zip',
    'libcurl4-openssl-dev',
    'libpq-dev',
    'libmysqlclient-dev',
    'libsqlite3-dev',
    'bzr',
  ].each do |package|
    it "installs #{package}" do
      expect(chef_run).to install_package(package)
    end
  end
end
