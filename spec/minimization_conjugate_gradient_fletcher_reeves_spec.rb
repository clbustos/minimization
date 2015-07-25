require "#{File.expand_path(File.dirname(__FILE__))}/../lib/multidim/conjugate_gradient.rb"

describe Minimization::FletcherReeves do

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

    # fletcher_reeves example 1
    puts @p.inspect
    f  = proc{ |x| (x[0] - @p[0])**2 + (x[1] - @p[1])**2 + (x[2] - @p[2])**2 }
    fd = proc{ |x| [ 2 * (x[0] - @p[0]) , 2 * (x[1] - @p[1]) , 2 * (x[2] - @p[2]) ] }
    @min1 = Minimization::FletcherReeves.minimize(f, fd, @start_point)

    # fletcher_reeves example 2
    @k = rand(@limit)
    f2  = proc{ |x| ( @p[0]*x[0] + @p[1]*x[1] + @p[2]*x[2] )**2 +  @k}
    fd2 = proc{ |x|
            r0 = ( @p[0]*x[0] + @p[1]*x[1] + @p[2]*x[2] ) * 2 * @p[0]
            r1 = ( @p[0]*x[0] + @p[1]*x[1] + @p[2]*x[2] ) * 2 * @p[1]
            r2 = ( @p[0]*x[0] + @p[1]*x[1] + @p[2]*x[2] ) * 2 * @p[2]
            [r0, r1, r2]
          }
    @min2 = Minimization::FletcherReeves.minimize(f2, fd2, @start_point)

    # fletcher_reeves example 3 : unidimensional
    f3  = proc{ |x| ( (x[0] - @p[0])**2 + @k ) }
    fd3 = proc{ |x| [ (x[0] - @p[0]) * 2 ] }
    starting_point_3 = [rand(@limit)]
    @min3 = Minimization::FletcherReeves.minimize(f3, fd3, starting_point_3)

  end

  it "#x_minimum be close to expected in example 1 :fletcher_reeves" do 
    0.upto(@n - 1) do |i|
      expect(@min1.x_minimum[i]).to be_within(@epsilon).of(@p[i])
    end
  end

  it "#f_minimum be close to expected in example 1 :fletcher_reeves" do 
    expect(@min1.f_minimum).to be_within(@epsilon).of(0)
  end

  it "#f_minimum be close to expected in example 2 :fletcher_reeves" do 
    expect(@min2.f_minimum).to be_within(@epsilon).of(@k)
  end

  it "#x_minimum be close to expected in example 3 :fletcher_reeves" do 
    expect(@min3.x_minimum[0]).to be_within(@epsilon).of(@p[0])
  end

  it "#f_minimum be close to expected in example 3 :fletcher_reeves" do 
    expect(@min3.f_minimum).to be_within(@epsilon).of(@k)
  end

end

