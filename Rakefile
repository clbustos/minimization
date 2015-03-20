require 'rake'
require 'bundler/gem_tasks'
require "rspec/core/rake_task"
require 'rdoc/task'

# Setup the necessary gems, specified in the gemspec.
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc "Open an irb session preloaded with distribution"
task :console do
  sh "irb -rubygems -I lib -r minimization.rb"
end

task :default => [:spec]

# vim: syntax=ruby
