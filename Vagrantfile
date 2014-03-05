# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

build_script = <<BUILD
#!/bin/bash -l
# required to load /etc/profile.d/gvm.sh

env | sort

type gvm # this should be a function, loaded by /etc/profile.d/gvm.sh

if ! gvm use 1.2; then
  echo 'Wrong Go version or GVM not installed.'
  exit 1
fi

if ! chruby 1.9.3; then
  echo 'Wrong Ruby version or chruby not installed.'
  exit 1
fi

echo 'All is well.'
exit 0
BUILD

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = 'opscode-ubuntu-13.04'

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-13.04_provisionerless.box'

  config.omnibus.chef_version = :latest

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :virtualbox do |vb|
    #   # Don't boot with headless mode
    #   vb.gui = true
    #
    #   # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ['modifyvm', :id, '--memory', '1024']
  end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  config.vm.define 'master' do |master|
    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    master.vm.network :private_network, ip: '192.168.33.10'

    # Enable provisioning with chef solo, specifying a cookbooks path, roles
    # path, and data_bags path (all relative to this Vagrantfile), and adding
    # some recipes and/or roles.
    #
    master.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = 'cookbooks'
      chef.add_recipe 'apt'
      chef.add_recipe 'cf-jenkins'
      chef.json = {
        'rubies' => {
          'list' => ['ruby 1.9.3-p484'],
          'install_bundler' => true
        },
        'chruby_install' => {
          'default_ruby' => '1.9.3-p484',
          'auto' => false
        },
        'selfsigned_certificate' => {
          'destination' => '/usr/var/ssl/certs/',
          'sslpassphrase' => 'changeme',
          'country' => 'CO',
          'state' => 'ST',
          'city' => 'CI',
          'orga' => 'OR',
          'depart' => 'DE',
          'cn' => 'CN',
          'email' => 'EMAIL'
        },
        'cf_jenkins' => {
          'ssh_known_hosts' => [],
          'jobs' => [
            { 'name' => 'dummy_job',
              'build_vars' => {
                'build_repo' => 'https://github.com/cloudfoundry-attic/tac.git',
                'build_repo_branch' => 'master',
                'build_shell_command' => build_script,
              }
            },
            {
              'name' => 'slave_job',
              'build_vars' => {
                'build_repo' => 'https://github.com/cloudfoundry-attic/tac.git',
                'build_repo_branch' => 'master',
                'build_shell_command' => build_script,
              }
            }
          ]
        }
      }
    end
  end

  config.vm.define 'slave' do |slave|
    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    slave.vm.network :private_network, ip: '192.168.33.11'

    # Enable provisioning with chef solo, specifying a cookbooks path, roles
    # path, and data_bags path (all relative to this Vagrantfile), and adding
    # some recipes and/or roles.
    #
    slave.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = 'cookbooks'
      chef.add_recipe 'apt'
      chef.add_recipe 'cf-jenkins::slave'
      chef.json = {
        'rubies' => {
          'list' => ['ruby 1.9.3-p484'],
          'install_bundler' => true
        },
        'chruby_install' => {
          'default_ruby' => '1.9.3-p484',
          'auto' => false
        },
        'jenkins' => {
          'server' => {
            'url' => 'http://192.168.33.10:8080'
          },
          'node' => {
            'name' => 'jenkins-slave'
          }
        },
        'cf_jenkins' => {
          'ssh_known_hosts' => [],
        }
      }
    end
  end
end
