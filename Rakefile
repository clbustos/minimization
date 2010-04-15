# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/minimization'
Hoe.plugin :git

Hoe.spec 'minimization' do
	self.version=Minimization::VERSION
	self.rubyforge_name = 'ruby-statsample' # if different than 'minimization'
	self.developer('Claudio Bustos', 'clbustos_AT_gmail.com')
	self.remote_rdoc_dir = 'minimization'
    self.extra_deps << ['text-table', "~>1.2"]
end

# vim: syntax=ruby
