require "./../lib/conjugate_gradient_minimizer.rb"

describe Minimization::NonLinearConjugateGradientMinimizer do

  before do
    @n           = 3
    @limit       = 100
    @epsilon     = 1e-5
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
    @min1 = Minimization::NonLinearConjugateGradientMinimizer.new(f, fd, @start_point, :fletcher_reeves)
    while(@min1.converging?)
      @min1.minimize
    end

    # example 2
    @k = rand(@limit)
    f2  = proc{ |x| ( @p[0]*x[0] + @p[1]*x[1] + @p[2]*x[2] )**2 +  @k}
    fd2 = proc{ |x|
            r0 = ( @p[0]*x[0] + @p[1]*x[1] + @p[2]*x[2] ) * 2 * @p[0]
            r1 = ( @p[0]*x[0] + @p[1]*x[1] + @p[2]*x[2] ) * 2 * @p[1]
            r2 = ( @p[0]*x[0] + @p[1]*x[1] + @p[2]*x[2] ) * 2 * @p[2]
            [r0, r1, r2]
          }
    @min2 = Minimization::NonLinearConjugateGradientMinimizer.new(f2, fd2, @start_point, :fletcher_reeves)
    while(@min2.converging?)
      @min2.minimize
    end

    # example 3 : unidimensional
    f3  = proc{ |x| ( (x[0] - @p[0])**2 + @k ) }
    fd3 = proc{ |x| [ (x[0] - @p[0]) * 2 ] }
    starting_point_3 = [rand(@limit)]
    @min3 = Minimization::NonLinearConjugateGradientMinimizer.new(f3, fd3, starting_point_3, :fletcher_reeves)
    while(@min3.converging?)
      @min3.minimize
    end

  end

  it "#x_minimum be close to expected in example 1" do 
    0.upto(@n - 1) do |i|
      @min1.x_minimum[i].should be_within(@epsilon).of(@p[i])
    end
  end

  it "#f_minimum be close to expected in example 1" do 
    @min1.f_minimum.should be_within(@epsilon).of(0)
  end

  it "#f_minimum be close to expected in example 2" do 
    @min2.f_minimum.should be_within(@epsilon).of(@k)
  end

  it "#x_minimum be close to expected in example 3" do 
    @min3.x_minimum[0].should be_within(@epsilon).of(@p[0])
  end

  it "#f_minimum be close to expected in example 3" do 
    @min3.f_minimum.should be_within(@epsilon).of(@k)
  end

end
