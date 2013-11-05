require 'spec_helper'

if defined?(ChefSpec)
  def update_jenkins_job(job_name)
    ChefSpec::Matchers::ResourceMatcher.new(:jenkins_job, :update, job_name)
  end
end

describe 'cf-jenkins::jobs' do
  subject(:chef_run) do
    ChefSpec::Runner.new(step_into: ['jenkins_job']) do |node|
      node.set['cf_jenkins'] = {
        'jobs' => [{name: 'FAKE_JOB'}],
      }
    end.converge(described_recipe)
  end

  it { should create_directory('/var/lib/jenkins/jobs/FAKE_JOB') }
  it { should create_template('/var/lib/jenkins/jobs/FAKE_JOB/config.xml') }

  it {
    pending "Having trouble figuring out how to test this properly"
    puts "\njob resource:\t#{chef_run.find_resource('jenkins_job', 'FAKE_JOB').inspect}\n\n"
    should update_jenkins_job('FAKE_JOB')
  }
end

