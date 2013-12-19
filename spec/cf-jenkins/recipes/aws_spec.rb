require 'spec_helper'

describe 'cf-jenkins::aws' do
  subject(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['aws'] = aws_config
    end.converge(described_recipe)
  end

  let(:jenkins_home) { chef_run.node[:jenkins][:server][:home] }
  let(:aws_config) { {} }

  it { should_not associate_aws_elastic_ip('jenkins ip') }
  it { should_not attach_aws_ebs_volume('jenkins_ebs_home') }
  it { should_not run_execute('format drive') }
  it { should_not create_directory(jenkins_home) }
  it { should_not enable_mount(jenkins_home) }

  context 'when node.aws.access_key and node.aws.secret_access_key are set' do
    let(:aws_access_key) { chef_run.node['aws']['access_key'] }
    let(:aws_secret_access_key) { chef_run.node['aws']['secret_access_key'] }

    let(:aws_config) do
      {
        'access_key' => 'ACCESS_KEY',
        'secret_access_key' => 'SECRET_ACCESS_KEY',
      }
    end

    before do
      Chef::Recipe.any_instance.stub(:require).with('right_aws')
    end

    it { should include_recipe('aws')}

    it { should_not associate_aws_elastic_ip('jenkins ip') }
    it { should_not attach_aws_ebs_volume('jenkins_ebs_home') }
    it { should_not run_execute('format drive') }
    it { should_not create_directory(jenkins_home) }
    it { should_not enable_mount(jenkins_home) }

    context 'when node.aws.elastic_ip is set' do
      let(:aws_config) do
        {
          'access_key' => 'ACCESS_KEY',
          'secret_access_key' => 'SECRET_ACCESS_KEY',
          'elastic_ip' => 'ELASTIC_IP',
        }
      end

      it { should associate_aws_elastic_ip('jenkins ip').
                    with(aws_access_key: aws_access_key,
                         aws_secret_access_key: aws_secret_access_key,
                         ip: 'ELASTIC_IP') }
      it { should_not attach_aws_ebs_volume('jenkins_ebs_home') }
      it { should_not run_execute('format drive') }
      it { should_not create_directory(jenkins_home) }
      it { should_not enable_mount(jenkins_home) }
    end

    context 'when node.aws.ebs_volume_id is set' do
      let(:aws_config) do
        {
          'access_key' => 'ACCESS_KEY',
          'secret_access_key' => 'SECRET_ACCESS_KEY',
          'ebs_volume_id' => 'EBS_VOLUME_ID',
        }
      end
      let(:formatted?) { true }

      before do
        stub_command('file -s /dev/xvdi | grep ext4').and_return(formatted?)
      end

      it { should_not associate_aws_elastic_ip('jenkins ip') }

      it { should attach_aws_ebs_volume('jenkins_ebs_home').
                    with(aws_access_key: aws_access_key,
                         aws_secret_access_key: aws_secret_access_key,
                         volume_id: 'EBS_VOLUME_ID',
                         device: '/dev/sdi') }
      it { should_not run_execute('format drive').with(command: 'mkfs -t ext4 /dev/xvdi') }
      it { should create_directory(jenkins_home).with(owner: 'root', group: 'root', mode: 00644) }
      it { should enable_mount(jenkins_home).with(device: '/dev/xvdi', fstype: 'ext4') }

      context 'when the drive is NOT formatted' do
        let(:formatted?) { false }

        it { should run_execute('format drive').with(command: 'mkfs -t ext4 /dev/xvdi') }
      end
    end
  end
end
