require 'jenkins_api_client'

JENKINS_BUILD_TIMEOUT = 300

RSpec::Matchers.define :successfully_build do |job_name|
  match do |jenkins_client|
    @build_number = jenkins_client.job.build(job_name, {}, true)

    start_time = Time.now
    job_success = false
    loop do
      build_details = jenkins_client.job.get_build_details(job_name, @build_number)
      if build_details['result']
        if build_details['result'] != 'SUCCESS'
          @error = "Job finished with result '#{build_details['result']}', expected 'SUCCESS'."
        elsif @node_name && build_details['builtOn'] != @node_name
          @error = "Job ran on node #{build_details['builtOn'].inspect}, expected it to run on #{@node_name.inspect}."
        else
          job_success = true
        end
        break
      end

      elapsed = Time.now - start_time
      if elapsed >= JENKINS_BUILD_TIMEOUT
        @error = "Build did not complete within #{JENKINS_BUILD_TIMEOUT} seconds"
        break
      end

      sleep(0.2)
    end
    job_success
  end

  failure_message_for_should do |jenkins_client|
    @error + "\n\nConsole output:\n" +
      jenkins_client.job.get_console_output(job_name, @build_number)['output']
  end

  chain :on_node do |node_name|
    @node_name = node_name
  end
end
