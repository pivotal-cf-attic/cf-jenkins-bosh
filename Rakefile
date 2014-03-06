require 'fileutils'
require 'rspec/core/rake_task'

task :default => :spec

desc 'Run all tests, unit and integration'
task :spec => %w(spec:unit spec:integration)

# hide this one from rake -T, use spec:unit instead
desc ''
RSpec::Core::RakeTask.new('spec:unit_examples') do |task|
  task.pattern = 'spec/cf-jenkins/**/*_spec.rb'
end

# hide this one from rake -T, use spec:integration instead
desc ''
RSpec::Core::RakeTask.new('spec:integration_examples') do |task|
  task.pattern = 'spec/integration/**/*_spec.rb'
end

namespace :spec do
  task :integration_setup => :spec_setup do
    system('vagrant up')
  end

  task :integration_teardown do
    system('vagrant destroy --force')
  end

  desc 'Run integration tests with setup and teardown'
  task :integration => %w(spec:integration_setup spec:integration_examples spec:integration_teardown)

  desc 'Run unit tests with setup'
  task :unit => %w(spec_setup spec:unit_examples)
end

task :spec_setup do
  system('librarian-chef install')
end
