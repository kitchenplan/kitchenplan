#require 'bundler/gem_tasks'
#require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'yard/rake/yardoc_task'
require 'yard'

YARD::Rake::YardocTask.new

RSpec::Core::RakeTask.new(:unit) do |t|
  t.rspec_opts = [].tap do |a|
    a.push('--color')
    a.push('--format progress')
  end.join(' ')
end

desc 'Run all tests'
task :test => [:unit ]

task :default => [:test]
