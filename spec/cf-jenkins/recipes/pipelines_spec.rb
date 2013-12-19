require 'spec_helper'

describe 'cf-jenkins::pipelines' do
  subject(:chef_run) do
    ChefSpec::Runner.new(step_into: ['jenkins_job']) do |node|
      node.set['jenkins'] = {
        'server' => {
          'home' => fake_jenkins_home
        }
      }
      node.set['cf_jenkins'] = {
        'pipelines' => {
          'example_project' => {
            'git' => 'https://github.com/org/release.git',
            'release_name' => 'my-release',
            'release_ref' => 'master',
            'infrastructure' => 'warden',
            'deployments_repo' => 'https://github.com/org/deployments.git',
            'deployment_name' => 'my_environment',
            'steps' => [
              'deploy'
            ]
          }
        }
      }
    end.converge(described_recipe)
  end

  let(:jenkins_user) { chef_run.node['jenkins']['server']['user'] }
  let(:jenkins_group) { jenkins_user }
  let(:fake_jenkins_home) { Dir.mktmpdir }
  let(:deploy_job_config) { File.join(fake_jenkins_home, 'jobs', 'example_project-deploy', 'config.xml') }
  let(:tests_job_config) { File.join(fake_jenkins_home, 'jobs', 'example_project-system_tests', 'config.xml') }
  let(:fake_chef_rest_for_jenkins_check) { double(Chef::REST::RESTRequest, call: double(Net::HTTPSuccess).as_null_object) }
  let(:ruby_setup) {
    <<-BASH
source /usr/local/share/chruby/chruby.sh
chruby 1.9.3
gem install bundler --no-ri --no-rdoc --conservative
bundle install
    BASH
  }
  let(:go_setup) {
    <<-BASH
source /usr/local/share/gvm/scripts/gvm
gvm use go1.2
    BASH
  }

  before do
    FileUtils.mkdir_p(File.dirname(deploy_job_config))
    FileUtils.touch(deploy_job_config)

    FileUtils.mkdir_p(File.dirname(tests_job_config))
    FileUtils.touch(tests_job_config)

    Chef::REST::RESTRequest.stub(new: fake_chef_rest_for_jenkins_check)
  end

  it 'adds nokogiri, so it can generate XML' do
    expect(chef_run).to install_chef_gem('nokogiri')
  end

  it { should create_directory(File.join(fake_jenkins_home, 'jobs', 'example_project-deploy')).with(mode: 00755) }

  it 'has a job for executing cf_deploy' do
    cf_deploy_options = %w(
    --non-interactive
    --release-name example_project
    --release-repo https://github.com/org/release.git
    --release-ref master
    --infrastructure warden
    --deployments-repo https://github.com/org/deployments.git
    --deployment-name my_environment
    --rebase
    ).join(' ')

    expected_command = <<-BASH
#!/bin/bash
set -x

#{ruby_setup}
#{go_setup}
SHELL=/bin/bash bundle exec cf_deploy #{cf_deploy_options}
    BASH

    should render_file(deploy_job_config).with_content(expected_command)
    should create_file(deploy_job_config).with(
      owner: jenkins_user,
      group: jenkins_group,
      mode: 00644,
    )
  end

  it { should update_jenkins_job('example_project-deploy').with(config: deploy_job_config) }

  it { should create_directory(File.join(fake_jenkins_home, 'jobs', 'example_project-system_tests')).with(mode: 00755) }

  it "has a job for running the project's system tests" do
    expected_command = <<-BASH
#!/bin/bash
set -x

#{ruby_setup}
#{go_setup}
script/run_system_tests
    BASH

    should render_file(tests_job_config).with_content(expected_command)
    should create_file(tests_job_config).with(
      owner: jenkins_user,
      group: jenkins_group,
      mode: 00644,
    )
  end

  it { should update_jenkins_job('example_project-system_tests').with(config: tests_job_config) }
end
