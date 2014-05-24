require './../../lib/minimization.rb'
include Minimization

min=Minimization::NelderMead.new(-1000,2000, 2, [0.0, 0.0], proc {|x, y| x[0]+x[1]*10})
min.iterate
