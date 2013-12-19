require 'nokogiri'

module JenkinsClient
  class Job
    attr_accessor :command, :description, :downstream_jobs, :git_repo_url, :git_repo_branch

    def downstream_jobs
      @downstream_jobs || []
    end

    def to_xml
       builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
         xml.project do
           xml.description description
           xml.builders do
             xml.public_send 'hudson.tasks.Shell' do
               xml.command command
             end
           end
           xml.scm(class: 'hudson.plugins.git.GitSCM', plugin: 'git@2.0') do
             xml.userRemoteConfigs do
               xml.public_send('hudson.plugins.git.UserRemoteConfig') do
                 xml.url git_repo_url
               end
             end
             xml.branches do
               xml.public_send('hudson.plugins.git.BranchSpec') do
                 xml.name git_repo_branch
               end
             end
           end

           xml.publishers do
             if downstream_jobs.any?
               xml.public_send("hudson.plugins.parameterizedtrigger.BuildTrigger", plugin: "parameterized-trigger@2.22") do
                 xml.configs do
                   xml.public_send("hudson.plugins.parameterizedtrigger.BuildTriggerConfig") do
                     xml.configs do
                       xml.public_send("hudson.plugins.git.GitRevisionBuildParameters", plugin: "git@2.0") do
                         xml.combineQueuedCommits false
                       end
                     end

                     xml.projects downstream_jobs.join(', ')
                     xml.condition "SUCCESS"
                     xml.triggerWithNoParameters false
                   end
                 end
               end
             end
           end
         end
       end
       builder.to_xml
    end
  end
end
