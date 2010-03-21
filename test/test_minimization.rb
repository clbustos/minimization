$:.unshift(File.dirname(__FILE__)+'/../lib/')
require "test/unit"
require "minimization"

class TestMinimization < Test::Unit::TestCase
   def setup
      @p1=rand(100)
      @p2=rand(100)
      @func=lambda {|x| (x-@p1)**2+@p2}
   end
   def test_facade
      min=Minimization::GoldenSection.minimize(-1000,1000) {|x| (x-@p1)**2+@p2}
      assert_in_delta(@p1,min.x_minimum, min.epsilon)
      assert_in_delta(@p2,min.f_minimum, min.epsilon)
   end
   def test_golden
      min=Minimization::GoldenSection.new(-1000,1000, @func)
      min.iterate
      assert_in_delta(@p1, min.x_minimum, min.epsilon)
      assert_in_delta(@p2, min.f_minimum, min.epsilon)
   end
   def test_brent
      min=Minimization::Brent.new(-1000,1000, @func)
      min.iterate
      assert_in_delta(@p1, min.x_minimum, min.epsilon)
      assert_in_delta(@p2, min.f_minimum, min.epsilon)
   end
end
