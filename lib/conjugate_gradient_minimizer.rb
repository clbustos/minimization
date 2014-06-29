require "#{File.dirname(__FILE__)}/point_value_pair.rb"
require "#{File.dirname(__FILE__)}/minimization.rb"
require "#{File.dirname(__FILE__)}/brent_root_finder.rb"

module Minimization

  class NonLinearConjugateGradientMinimizer

    attr_reader :x_minimum
    attr_reader :f_minimum

    attr_accessor :initial_step

    MAX_EVALUATIONS_DEFAULT = 100000
    MAX_ITERATIONS_DEFAULT  = 100000

    def initialize(f, fd, start_point, beta_formula)
      @epsilon     = 10e-5
      @safe_min    = 4.503599e15
      @f           = f
      @fd          = fd
      @start_point = start_point

      @max_iterations     = MAX_ITERATIONS_DEFAULT
      @max_evaluations    = MAX_EVALUATIONS_DEFAULT
      @iterations         = 0
      @update_formula     = beta_formula
      @relative_threshold = 100 * @epsilon
      @absolute_threshold = 100 * @safe_min

      @initial_step = 1.0 # initial step default
      @converging   = true

      # do initial steps
      @point = @start_point.clone
      @n      = @point.length
      @r      = gradient(@point)
      0.upto(@n - 1) do |i|
        @r[i] = -@r[i]
      end
      
      # Initial search direction.
      @steepest_descent = precondition(@point, @r)
      @search_direction = @steepest_descent.clone

      @delta = 0
      0.upto(@n - 1) do |i|
          @delta += @r[i] * @search_direction[i]
      end
      @current = nil
    end

    # return the convergence of the search
    def converging?
      return @converging
    end

    def f(x)
      @iterations += 1
      raise "max evaluation limit exeeded: #{@max_iterations}" if @iterations > @max_iterations
      return @f.call(x)
    end

    def gradient(x)
      return @fd.call(x)
    end

    def find_upper_bound(a, h, search_direction)
      ya   = line_search_func(a, search_direction)
      yb   = ya
      step = h
      # check step value for float max value exceeds
      while step < Float::MAX
        b  = a + step
        yb = line_search_func(b, search_direction)
        if (ya * yb <= 0)
          return b
        end
        step *= [2, ya / yb].max
      end
      # raise error if bracketing failed
      raise "Unable to bracket minimum in line search."
    end

    def precondition(point, r)
      return r.clone # case: identity preconditioner has been used as the default
    end

    def converged(previous, current)
      p          = f(previous)
      c          = f(current)
      difference = (p - c).abs
      size       = [p.abs, c.abs].max
      return ((difference <= size * @relative_threshold) or (difference <= @absolute_threshold))
    end

    # solver to use during line search
    def solve(min, max, start_value, search_direction)
      # check start_value to eliminate unnessasary calculations ...
      func        = proc{|x| line_search_func(x, search_direction)}
      root_finder = Minimization::BrentRootFinder.new(func)
      root        = root_finder.find_root(min, max, func)
      return root
    end

    def line_search_func(x, search_direction)
      # current point in the search direction
      shifted_point = @point.clone
      0.upto(shifted_point.length - 1) do |i|
        shifted_point[i] += x * search_direction[i]
      end

      # gradient of the objective function
      gradient = gradient(shifted_point)

      # dot product with the search direction
      dot_product = 0
      0.upto(gradient.length - 1) do |i|
        dot_product += gradient[i] * search_direction[i]
      end

      return dot_product
    end
    
    def minimize
      @iterations  += 1
      @previous     = @current
      @current      = Minimization::PointValuePair.new(@point, f(@point))
      # set converging parameter
      @converging   = !(@previous != nil and converged(@previous.point, @current.point))
      # set results
      @x_minimum    = @current.point
      @f_minimum    = @current.value

      # set search_direction to be used in solve and find_upper_bound methods
      ub   = find_upper_bound(0, @initial_step, @search_direction)
      step = solve(0, ub, 1e-15, @search_direction)

      # Validate new point
      0.upto(@point.length - 1) do |i|
        @point[i] += step * @search_direction[i]
      end

      @r = gradient(@point)
      0.upto(@n - 1) do |i|
        @r[i] = -@r[i]
      end

      # Compute beta
      delta_old            = @delta
      new_steepest_descent = precondition(@point, @r)
      @delta                = 0
      0.upto(@n - 1) do |i|
        @delta += @r[i] * new_steepest_descent[i]
      end

      if (@update_formula == :fletcher_reeves)
        beta = @delta / delta_old
      elsif(@update_formula == :polak_ribiere)
        deltaMid = 0
        0.upto(@r.length - 1) do |i|
          deltaMid += @r[i] * @steepest_descent[i]
        end
        beta = (@delta - deltaMid) / delta_old
      else
        raise "Unknown beta formula type"
      end
      @steepest_descent = new_steepest_descent

      # Compute conjugate search direction
      if ((@iterations % @n == 0) or (beta < 0))
        # Break conjugation: reset search direction
        @search_direction = @steepest_descent.clone
      else
        # Compute new conjugate search direction
        0.upto(@n - 1) do |i|
          @search_direction[i] = @steepest_descent[i] + beta * @search_direction[i]
        end
      end
    end

  end

end
