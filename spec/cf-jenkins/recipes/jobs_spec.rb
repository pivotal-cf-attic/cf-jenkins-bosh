require 'spec_helper'
require 'fileutils'
require 'tmpdir'

describe 'cf-jenkins::jobs' do
  subject(:chef_run) do
    ChefSpec::Runner.new(step_into: ['jenkins_job']) do |node|
      node.set['jenkins'] = {
        'server' => {
          'home' => fake_jenkins_home
        }
      }
      node.set['cf_jenkins'] = {
        'jobs' => [
          {
            name: 'FAKE_JOB',
            build_flow: use_build_flow?,
            build_vars: {fake: 'vars'}
          }
        ],
      }
    end.converge(described_recipe)
  end

  let(:jenkins_user) { chef_run.node['jenkins']['server']['user'] }
  let(:jenkins_group) { jenkins_user }
  let(:use_build_flow?) { false }
  let(:fake_jenkins_home) { Dir.mktmpdir }
  let(:job_config) { File.join(fake_jenkins_home, 'jobs', 'FAKE_JOB', 'config.xml') }
  let(:fake_chef_rest_for_jenkins_check) { double(Chef::REST::RESTRequest, call: double(Net::HTTPSuccess).as_null_object) }

  before do
    FileUtils.mkdir_p(File.dirname(job_config))
    File.write(job_config, 'FAKE XML')

    Chef::REST::RESTRequest.stub(new: fake_chef_rest_for_jenkins_check)
  end

  it { should create_directory(File.join(fake_jenkins_home, 'jobs', 'FAKE_JOB')).with(mode: 00755) }

  it { should create_template(job_config).
                with(source: 'config.xml.erb',
                     owner: jenkins_user,
                     group: jenkins_group,
                     mode: 00644,
                     variables: {'fake' => 'vars'}) }
  it { should update_jenkins_job('FAKE_JOB').with(config: job_config) }

  context 'when using build_flow' do
    let(:use_build_flow?) { true }

    it { should create_template(job_config).
                  with(source: 'build-flow-config.xml.erb',
                       owner: jenkins_user,
                       group: jenkins_group,
                       mode: 00644,
                       variables: {'fake' => 'vars'}) }
  end
end
