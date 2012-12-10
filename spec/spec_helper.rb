$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'minimization.rb'
require 'rspec'
require 'rspec/autorun'

RSpec.configure do |config|
  
end

class String
  def deindent
    gsub /^[ \t]*/, ''
  end
end
