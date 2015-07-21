require "#{File.expand_path(File.dirname(__FILE__))}/../lib/multidim/nelder_mead.rb"

describe Minimization::NelderMead do
  before :all do
    @n           = 3
    @limit       = 100
    @epsilon     = 1e-6
    @p           = Array.new(@n)
    @start_point = Array.new(@n)

    0.upto(@n - 1) do |i|
      @p[i] = rand(@limit)
    end

    0.upto(@n - 1) do |i|
      @start_point[i] = rand(@limit)
    end

    # example 1
    f = proc{ |x| (x[0] - @p[0])**2 + (x[1] - @p[1])**2 + (x[2] - @p[2])**2 }
    @min1 = Minimization::NelderMead.minimize(f, @start_point)

    # example 2
    @k = rand(@limit)
    f2 = proc{ |x| ( @p[0]*x[0] + @p[1]*x[1] + @p[2]*x[2] )**2 +  @k}
    @min2 = Minimization::NelderMead.minimize(f2, @start_point)

    # example 3 : unidimensional
    f3 = proc{ |x| (x[0] - @p[0])**2 + @k}
    @min3 = Minimization::NelderMead.minimize(f3, [@k])
  end

  it "#x_minimum be close to expected in example 1" do 
    0.upto(@n - 1) do |i|
      expect(@min1.x_minimum[i]).to be_within(@epsilon).of(@p[i])
    end
  end

  it "#f_minimum be close to expected in example 1" do 
    expect(@min1.f_minimum).to be_within(@epsilon).of(0)
  end

  it "#f_minimum be close to expected in example 2" do 
    expect(@min2.f_minimum).to be_within(@epsilon).of(@k)
  end

  it "#x_minimum be close to expected in example 3" do 
    expect(@min3.x_minimum[0]).to be_within(@epsilon).of(@p[0])
  end

  it "#f_minimum be close to expected in example 3" do 
    expect(@min3.f_minimum).to be_within(@epsilon).of(@k)
  end

end


