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
  let(:job_config) { File.join(fake_jenkins_home, 'jobs', 'example_project-deploy', 'config.xml') }
  let(:fake_chef_rest_for_jenkins_check) { double(Chef::REST::RESTRequest, call: double(Net::HTTPSuccess).as_null_object) }

  before do
    FileUtils.mkdir_p(File.dirname(job_config))
    File.write(job_config, 'FAKE XML')

    Chef::REST::RESTRequest.stub(new: fake_chef_rest_for_jenkins_check)
  end

  it { should create_directory(File.join(fake_jenkins_home, 'jobs', 'example_project-deploy')).with(mode: 00755) }

  it 'sets up the environment and executes cf_deploy' do
    cf_deploy_options = %w(
    --non-interactive
    --release-name example_project
    --release-repo https://github.com/org/release.git
    --release-ref master
    --infrastructure warden
    --deployments-repo https://github.com/org/deployments.git
    --deployment-name my_environment
    ).join(' ')

    expected_command = <<-BASH
#!/bin/bash
set -x

source /usr/local/share/chruby/chruby.sh
chruby 1.9.3
gem install bundler --no-ri --no-rdoc --conservative
bundle install

SHELL=/bin/bash bundle exec cf_deploy #{cf_deploy_options}
    BASH

    should create_template(job_config).
      with(source: 'config.xml.erb',
           owner: jenkins_user,
           group: jenkins_group,
           mode: 00644,
           variables: {
             'build_shell_command' => expected_command,
             'build_repo' => 'https://github.com/org/release.git',
             'build_repo_branch' => 'master'
           })
  end

  it { should update_jenkins_job('example_project-deploy').with(config: job_config) }
end
