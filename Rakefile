# -*- ruby -*-

require 'rubygems'
require 'bundler'
require './lib/minimization'

gemspec = eval(IO.read("minimization.gemspec"))

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "rubygems/package_task"
Gem::PackageTask.new(gemspec).define

desc "install the gem locally"
task :install => [:package] do
  sh %{gem install pkg/minimization-#{Minimization::VERSION}.gem}
end

require 'rspec/core/rake_task'
require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

# git log --pretty=format:"*%s[%cn]" v0.5.0..HEAD >> History.txt
desc "Open an irb session preloaded with distribution"
task :console do
  sh "irb -rubygems -I lib -r minimization.rb"
end

task :default => :spec
# vim: syntax=ruby

