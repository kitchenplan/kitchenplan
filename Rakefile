# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "kitchenplan"
  gem.homepage = "http://github.com/kitchenplan/kitchenplan"
  gem.license = "Apache 2.0"
  gem.summary = %Q{Kitchenplan is a small tool to fully automate the installation and configuration of an OSX workstation using chef}
  gem.description = %Q{Kitchenplan is a small tool to fully automate the installation and configuration of an OSX workstation (or server for that matter) using Chef. But while doing so manually is not a trivial undertaking, Kitchenplan has abstracted away all the hard parts.}
  gem.email = "roderik@vanderveer.be"
  gem.authors = ["Roderik van der Veer"]
  gem.executables = %w(kitchenplan)
  gem.files = Dir.glob("{lib,templates}/**/*")
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "kitchenplan #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
