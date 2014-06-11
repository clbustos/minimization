require "./point_value_pair.rb"
require "./minimization.rb"

module Minimization
  class ConjugateDirectionOptimizer

    Max_Iterations_Default = 100
    Max_Evaluations_Default = 100

    def initialize(f, initial_guess, lower_bound, upper_bound)
      @iterations = 0
      @max_iterations = Max_Iterations_Default
      @evaluations = 0
      @max_evaluations = Max_Evaluations_Default
      @f = f
      @start = initial_guess
      @lower_bound = lower_bound
      @upper_bound = upper_bound
      @line_minimizer = Minimization::Brent.new(1, 19, f)
      check_parameters

    end

    def f(x)
      @f.call(x)
    end
    
    def check_parameters
          if (!@start.nil?)
              dim = @start.length
              if (!@lower_bound.nil?)
                  if (@lower_bound.length != dim)
                      #throw new DimensionMismatchException(@lower_bound.length, dim);
                      
                  end
                  0.upto(dim - 1) do |i|
                      v = @start[i]
                      lo = @lower_bound[i]
                      if (v < lo)
                          #throw new NumberIsTooSmallException(v, lo, true);
                      end
                  end
              end
              if (!@upper_bound.nil?)
                  if (@upper_bound.length != dim) 
                      #throw new DimensionMismatchException(@upper_bound.length, dim);
                  end
                  0.upto(dim - 1) do |i|
                      v = @start[i]
                      hi = @upper_bound[i]
                      if (v > hi)
                          #throw new NumberIsTooLargeException(v, hi, true);
                      end
                  end
              end

              if (@lower_bound.nil?)
                  @lower_bound = Array.new(dim)
                  0.upto(dim - 1) do |i|
                      @lower_bound[i] = Float::INFINITY
                  end
              end
              if (@upper_bound.nil?)
                  @upper_bound = Array.new(dim)
                  0.upto(dim - 1) do |i|
                      @upper_bound[i] = -Float::INFINITY
                  end
              end
          end
      end

  end

  class PowellOptimizer < ConjugateDirectionOptimizer
    
    def initialize(f, initial_guess, lower_bound, upper_bound)
      super(f, initial_guess.clone, lower_bound, upper_bound)
      @relative_threshold = 1
      @absolute_threshold = 1
    end

    def new_point_and_direction(p, d, optimum)
          n = p.length
          np = Array.new(n)
          nd = Array.new(n)
          0.upto(n - 1) do |i|
              nd[i] = d[i] * optimum
              np[i] = p[i] + nd[i]
          end

          #result = Array.new(2)
          #result[0] = np
          #result[1] = nd
          return np, nd #result
    end

    def optimize
        
    end

    def line_search

    end

  end
end

f = proc{ |x| (x[0] - 11)**2 }
x = Minimization::PowellOptimizer.new(f, [1,2], [0, 0], [5, 5])
