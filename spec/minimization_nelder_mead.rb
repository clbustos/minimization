require "./../lib/nelder_mead.rb"

describe Minimization::NelderMead do
    before do
      @p1  = rand(100)
      @p2  = rand(100)
      f    = proc {|x| (x[0] - @p1)**2 + (x[1] - @p2)**2}
      @min = NelderMead.new(f, [1, 2])
      until(@min.converged)
        @min.iterate
      end
    end

    it "#x_minimum be close to expected" do 
      @min.x_minimum[0].should be_within(@min.EPSILON).of(@p1)
      @min.x_minimum[1].should be_within(@min.EPSILON).of(@p2)
    end
    it "#f_minimum be close to expected" do 
      @min.f_minimum.should be_within(@min.EPSILON).of(0)
    end
end


