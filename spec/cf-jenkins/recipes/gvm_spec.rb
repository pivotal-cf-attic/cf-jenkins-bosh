require 'spec_helper'

describe 'cf-jenkins::gvm' do
  subject(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
  let(:gvm_installer) { File.join(Chef::Config[:file_cache_path], 'gvm-installer') }

  it { should install_package('curl') }
  it { should install_package('git') }
  it { should install_package('mercurial') }
  it { should install_package('make') }
  it { should install_package('binutils') }
  it { should install_package('bison') }
  it { should install_package('gcc') }
  it { should install_package('bzr') }

  it { should create_remote_file(gvm_installer).with(mode: 0755, source: 'https://raw.github.com/moovweb/gvm/master/binscripts/gvm-installer') }
  it { should run_bash('install go 1.2').with(code: 'source /usr/local/share/gvm/scripts/gvm && gvm install go1.2') }
  it { should create_file('/etc/profile.d/gvm.sh').with(mode: 0755) }

  describe 'installing GVM' do
    let(:gvm_script) { '/usr/local/share/gvm/scripts/gvm' }
    context 'when GVM was already installed' do
      before do
        exists = File.method(:exists?)
        File.stub(:exists?) do |thing|
          thing == gvm_script || exists[thing]
        end
      end
      it { should_not run_bash('install GVM') }
    end

    context 'when GVM has not been installed yet' do
      before do
        exists = File.method(:exists?)
        File.stub(:exists?) do |thing|
          exists[thing] if thing != gvm_script
        end
      end
      it { should run_bash('install GVM').with(code: "#{gvm_installer} master /usr/local/share") }
    end
  end
end
