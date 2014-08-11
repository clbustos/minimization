# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)


Gem::Specification.new do |s|
  s.name = "minimization"
  s.version = "0.2.1"
  s.authors = ["Claudio Bustos"]
  s.description = "Minimization algorithms on pure Ruby"
  s.email = ["clbustos@gmail.com"]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "lib/multidim"]
  #s.homepage = "http://ruby-statsample.rubyforge.org/""
  s.summary = "A suite for minimization in Ruby"
  s.add_runtime_dependency 'text-table', '~>1.2'
  s.add_runtime_dependency 'rb-gsl', '~>1.2'
  s.add_development_dependency 'rake', '~>10'
  s.add_development_dependency 'bundler', '~>1.3'
  s.add_development_dependency 'rspec', '~>2.0'
  s.add_development_dependency 'rubyforge', '~>2.0'
end

