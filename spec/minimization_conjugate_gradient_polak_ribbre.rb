require "./../lib/conjugate_gradient_minimizer.rb"

describe Minimization::NonLinearConjugateGradientMinimizer do

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
    f  = proc{ |x| (x[0] - @p[0])**2 + (x[1] - @p[1])**2 + (x[2] - @p[2])**2 }
    fd = proc{ |x| [ 2 * (x[0] - @p[0]) , 2 * (x[1] - @p[1]) , 2 * (x[2] - @p[2]) ] }
    @min1 = Minimization::NonLinearConjugateGradientMinimizer.new(f, fd, @start_point, :polak_ribiere)
    while(@min1.converging?)
      @min1.minimize
    end

    # example 2 : unidimensional
    @k = rand(@limit)
    f2  = proc{ |x| ( (x[0] - @p[0])**2 + @k ) }
    fd2 = proc{ |x| [ (x[0] - @p[0]) * 2 ] }
    starting_point_2 = [rand(@limit)]
    @min2 = Minimization::NonLinearConjugateGradientMinimizer.new(f2, fd2, starting_point_2, :polak_ribiere)
    while(@min2.converging?)
      @min2.minimize
    end

  end

  it "#x_minimum be close to expected in example 1 :polak_ribiere" do 
    0.upto(@n - 1) do |i|
      expect(@min1.x_minimum[i]).to be_within(@epsilon).of(@p[i])
    end
  end

  it "#f_minimum be close to expected in example 1 :polak_ribiere" do 
    expect(@min1.f_minimum).to be_within(@epsilon).of(0)
  end

  it "#x_minimum be close to expected in example 2 :polak_ribiere" do 
    expect(@min2.x_minimum[0]).to be_within(@epsilon).of(@p[0])
  end

  it "#f_minimum be close to expected in example 2 :polak_ribiere" do 
    expect(@min2.f_minimum).to be_within(@epsilon).of(@k)
  end

end


