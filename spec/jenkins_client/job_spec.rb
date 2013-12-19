require 'spec_helper'
require_relative '../../libraries/job'

describe JenkinsClient::Job do
  it 'serializes the description' do
    job = JenkinsClient::Job.new
    job.description = "Best job ever"

    xml = job.to_xml
    doc = Nokogiri::XML(xml)
    expect(doc.xpath('//project/description').text).to eq('Best job ever')
  end

  matcher(:have_git_repo_url) do |expected_url|
    match do |xml|
      doc = Nokogiri::XML(xml)
      doc.xpath('//scm[@class="hudson.plugins.git.GitSCM"]').first['plugin'] == "git@2.0" &&
        doc.xpath('//scm/userRemoteConfigs/hudson.plugins.git.UserRemoteConfig/url').text == expected_url
    end

    failure_message_for_should do |xml|
      "Expected to find git repo URL #{expected_url} in:\n#{xml}"
    end
  end

  matcher(:have_git_repo_branch) do |expected_branch_name|
    match do |xml|
      doc = Nokogiri::XML(xml)
      doc.xpath('//scm[@class="hudson.plugins.git.GitSCM"]').first['plugin'] == "git@2.0" &&
        doc.xpath('//scm/branches/hudson.plugins.git.BranchSpec/name').text == expected_branch_name
    end

    failure_message_for_should do |xml|
      "Expected to find git repo branch name #{expected_branch_name} in:\n#{xml}"
    end
  end

  matcher(:have_command) do |expected_command|
    match do |xml|
      doc = Nokogiri::XML(xml)
      doc.xpath('//builders/hudson.tasks.Shell/command').text == expected_command
    end

    failure_message_for_should do |xml|
      "Expected to find command #{expected_command} in:\n#{xml}"
    end
  end

  matcher(:have_downstream_jobs) do |expected_project_names|
    match do |xml|
      doc = Nokogiri::XML(xml)
      xpath = '//publishers/hudson.plugins.parameterizedtrigger.BuildTrigger/configs/hudson.plugins.parameterizedtrigger.BuildTriggerConfig/projects'
      doc.xpath(xpath).first.text.split(", ").sort == expected_project_names.sort
    end

    failure_message_for_should do |xml|
      "Expected to find downstream jobs #{expected_project_names.join(', ')} in:\n#{xml}"
    end
  end

  it 'serializes the git SCM config' do
    job = JenkinsClient::Job.new
    job.git_repo_url = "https://github.com/org/repo"
    job.git_repo_branch = "master"

    expect(job.to_xml).to have_git_repo_url('https://github.com/org/repo')
    expect(job.to_xml).to have_git_repo_branch('master')
  end

  it 'serializes the command' do
    job = JenkinsClient::Job.new
    job.command = 'release-the-hounds'

    expect(job.to_xml).to have_command('release-the-hounds')
  end

  it 'serializes the downstream jobs' do
    job = JenkinsClient::Job.new
    job.downstream_jobs = ['other-project', 'different-project']

    expect(job.to_xml).to have_downstream_jobs(['other-project', 'different-project'])
  end
end
