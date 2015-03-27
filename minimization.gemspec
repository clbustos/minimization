$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'date'
require 'minimization/version'

Gem::Specification.new do |s|
  s.name = "minimization"
  s.version = Minimization::VERSION
  s.date = Date.today.to_s

  s.authors = ["Claudio Bustos", "Rajat Kapoor"]
  s.email = ["clbustos@gmail.com", "rajat100493@gmail.com"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.homepage = "https://github.com/sciruby/minimization"

  s.description = "Minimization algorithms on pure Ruby"
  s.summary = "A suite for minimization in Ruby"

  s.add_runtime_dependency 'text-table', '~>1.2'
  s.add_runtime_dependency 'rb-gsl', '~>1.2'
  s.add_development_dependency 'rake', '~>10'
  s.add_development_dependency 'bundler', '~>1.3'
  s.add_development_dependency 'rspec', '~>2.0'
  s.add_development_dependency 'rubyforge', '~>2.0'
end
