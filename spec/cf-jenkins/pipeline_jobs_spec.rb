require 'spec_helper'
require 'fileutils'
require 'tmpdir'

describe 'cf-jenkins::pipeline_jobs' do
  subject(:chef_run) do
    ChefSpec::Runner.new(step_into: ['jenkins_job']) do |node|
      node.set['jenkins'] = {
        'server' => {
          'home' => fake_jenkins_home
        }
      }
      node.set['cf_jenkins'] = {
        'pipeline_jobs' => [
          {
            name: 'FAKE_SEED_JOB',
            code: 'some groovy code'
          }
        ],
      }
    end.converge(described_recipe)
  end

  let(:jenkins_user) { chef_run.node['jenkins']['server']['user'] }
  let(:jenkins_group) { jenkins_user }
  let(:fake_jenkins_home) { Dir.mktmpdir }
  let(:job_config_path) { File.join(fake_jenkins_home, 'jobs', 'FAKE_SEED_JOB', 'config.xml') }
  let(:fake_chef_rest_for_jenkins_check) { double(Chef::REST::RESTRequest, call: double(Net::HTTPSuccess).as_null_object) }

  before do
    FileUtils.mkdir_p(File.dirname(job_config_path))
    File.write(job_config_path, 'FAKE XML')

    Chef::REST::RESTRequest.stub(new: fake_chef_rest_for_jenkins_check)
  end

  it { should create_directory(File.join(fake_jenkins_home, 'jobs', 'FAKE_SEED_JOB')).with(mode: 00755) }

  it { should create_template(job_config_path).
                with(source: 'job_dsl_config.xml.erb',
                     owner: jenkins_user,
                     group: jenkins_group,
                     mode: 00644,
                     variables: {'code' => 'some groovy code'}) }
  it { should update_jenkins_job('FAKE_SEED_JOB').with(config: job_config_path) }
end
