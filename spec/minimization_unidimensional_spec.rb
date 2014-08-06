require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe Minimization::Unidimensional, "subclass" do 
  before(:all) do
    @p1=rand(100)
    @p2=rand(100)
    @func=lambda {|x| (x-@p1)**2+@p2}
    @funcd=lambda {|x| 2*(x-@p1)}
    @funcdd=lambda  {|x| 2}
  end
  
  describe Minimization::NewtonRaphson  do
    before do
      @min = Minimization::NewtonRaphson.new(-1000,1000, @func,@funcd, @funcdd)
      @min.iterate
    end
    it "#x_minimum be close to expected" do 
      @min.x_minimum.should be_within(@min.epsilon).of(@p1)
    end
    it "#f_minimum ( f(x)) be close to expected" do 
      @min.f_minimum.should be_within(@min.epsilon).of(@p2)
    end
    context "#log" do
      subject {@min.log}
      it {should be_instance_of Array}
      it {should respond_to :to_table}
    end
  end
  
  
  describe Minimization::GoldenSection  do
    before do
      @min = Minimization::GoldenSection.minimize(-1000,1000, &@func)
    end
    it "#x_minimum be close to expected" do 
      @min.x_minimum.should be_within(@min.epsilon).of(@p1)
    end
    it "#f_minimum ( f(x)) be close to expected" do 
      @min.f_minimum.should be_within(@min.epsilon).of(@p2)
    end
    context "#log" do
      subject {@min.log}
      it {should be_instance_of Array}
      it {should respond_to :to_table}
    end
  end
  describe Minimization::Brent  do
    before do
      @min = Minimization::Brent.minimize(-1000,1000, &@func)
    end
    it "should x be correct" do 
      @min.x_minimum.should be_within(@min.epsilon).of(@p1)
    end
    it "should f(x) be correct" do 
      @min.f_minimum.should be_within(@min.epsilon).of(@p2)
    end
    context "#log" do
      subject {@min.log}
      it {should be_instance_of Array}
      it {should respond_to :to_table}
    end
  end
end
