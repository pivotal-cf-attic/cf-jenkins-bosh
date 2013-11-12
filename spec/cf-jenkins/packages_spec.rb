require 'spec_helper'

describe 'cf-jenkins::packages' do
  subject(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it { should install_package('curl') }
  it { should install_package('htop') }
  it { should install_package('vim') }
  it { should install_package('libxslt-dev') }
  it { should install_package('libxml2-dev') }
  it { should install_package('maven') }
  it { should install_package('zip') }
  it { should install_package('libcurl4-openssl-dev') }
  it { should install_package('libpq-dev') }
  it { should install_package('libmysqlclient-dev') }
  it { should install_package('libsqlite3-dev') }
  it { should install_package('bzr') }

  it { should install_package('qt4-dev-tools ') }
  it { should install_package('libqt4-dev ') }
  it { should install_package('libqt4-core ') }
  it { should install_package('libqt4-gui') }
end
