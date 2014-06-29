# = powell.rb -
# Minimization- Minimization algorithms on pure Ruby
# Copyright (C) 2010 Claudio Bustos
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# This algorith was adopted and ported into Ruby from Apache-commons
# Math library's PowellOptimizer.java and
# BaseAbstractMultivariateVectorOptimizer.java 
# files. Therefore this file is under Apache License Version 2.
#
# Powell's Algorithm for Multidimensional minimization
require "#{File.dirname(__FILE__)}/point_value_pair.rb"
require "#{File.dirname(__FILE__)}/minimization.rb"

module Minimization
  class ConjugateDirectionMinimizer
    attr_accessor :max_iterations
    attr_accessor :max_evaluations
    attr_accessor :max_brent_iterations
    attr_accessor :x_minimum
    attr_accessor :f_minimum

    # default maximum Powell's iteration value
    Max_Iterations_Default      = 100
    # default Max function evaluation value
    Max_Evaluations_Default     = 100
    # default Brent iteration value
    MAX_BRENT_ITERATION_DEFAULT = 10   # give a suitable value

    def initialize(f, initial_guess, lower_bound, upper_bound)
      @iterations           = 0
      @max_iterations       = Max_Iterations_Default
      @evaluations          = 0
      @max_evaluations      = Max_Evaluations_Default
      @max_brent_iterations = MAX_BRENT_ITERATION_DEFAULT
      @converging           = true

      # set minimizing function
      @f                    = f
      @start                = initial_guess
      @lower_bound          = lower_bound
      @upper_bound          = upper_bound

      # set maximum and minimum coordinate value a point can have
      # while minimization process
      @min_coordinate_val   = lower_bound.min
      @max_coordinate_val   = upper_bound.max

      # validate input parameters
      check_parameters
    end

    # return the convergence of the search
    def converging?
      return @converging
    end

    # set minimization function
    def f(x)
      # check whether maximum iterations limit reached
      raise "Too many evaluations : #{@max_evaluations}" if @evaluations > @max_evaluations
      @f.call(x)
    end
    
    # validate input parameters
    def check_parameters
      if (!@start.nil?)
        dim = @start.length
        if (!@lower_bound.nil?)
          # check for dimension mismatches
          raise "dimension mismatching #{@lower_bound.length} and #{dim}" if @lower_bound.length != dim
          # check whether start point exeeds the lower bound
          0.upto(dim - 1) do |i|
            v = @start[i]
            lo = @lower_bound[i]
            raise "start point is lower than lower bound" if v < lo
          end
        end
        if (!@upper_bound.nil?)
          # check for dimension mismatches
          raise "dimension mismatching #{@upper_bound.length} and #{dim}" if @upper_bound.length != dim
          # check whether strating point exceeds the upper bound
          0.upto(dim - 1) do |i|
            v = @start[i]
            hi = @upper_bound[i]
            raise "start point is higher than the upper bound" if v > hi
          end
        end

        if (@lower_bound.nil?)
          @lower_bound = Array.new(dim)
          0.upto(dim - 1) do |i|
            @lower_bound[i] = Float::INFINITY # eventually this will occur an error
          end
        end
        if (@upper_bound.nil?)
          @upper_bound = Array.new(dim)
          0.upto(dim - 1) do |i|
            @upper_bound[i] = -Float::INFINITY # eventually this will occur an error
          end
        end
      end
    end

    # line minimization using Brent's minimization
    # == Parameters:
    # * <tt>point</tt>: Starting point
    # * <tt>direction</tt>: Search direction
    #
    def brent_search(point, direction)
      n = point.length
      # Create a proc to minimize using brent search
      # Function value varies with alpha value and represent a point
      # of the minimizing function which is on the given plane
      func = proc{ |alpha|
        x = Array.new(n)
        0.upto(n - 1) do |i|
          # create a point according to the given alpha value
          x[i] = point[i] + alpha * direction[i]
        end
        # return the function value of the obtained point
        f(x)
      }

      # create Brent minimizer
      line_minimizer = Minimization::Brent.new(@min_coordinate_val, @max_coordinate_val, func)
      # iterate Brent minimizer for given number of iteration value
      0.upto(@max_brent_iterations) do
        line_minimizer.iterate
      end
      # return the minimum point
      return {:alpha_min => line_minimizer.x_minimum, :f_val => line_minimizer.f_minimum}
    end

  end

  # = Powell's Minimizer.
  # A multidimensional minimization methods
  # == Usage.
  #  require 'minimization'
  #  f = proc{ |x| (x[0] - 1)**2 + (2*x[1] - 5)**2 + (x[2]-3.3)**2}
  #  min = Minimization::PowellMinimizer.new(f, [1, 2, 3], [0, 0, 0], [5, 5, 5])
  #  while(min.converging?)
  #    min.minimize
  #  end
  #  min.f_minimum
  #  min.x_minimum
  #
  class PowellMinimizer < ConjugateDirectionMinimizer

    attr_accessor :relative_threshold
    attr_accessor :absolute_threshold

    # default of relative threshold
    RELATIVE_THRESHOLD_DEFAULT = 0.1
    # default of absolute threshold
    ABSOLUTE_THRESHOLD_DEFAULT =0.1
    
    # == Parameters:
    # * <tt>f</tt>: Minimization function
    # * <tt>initial_guess</tt>: Initial position of Minimization
    # * <tt>lower_bound</tt>: Lower bound of the minimization
    # * <tt>upper_bound</tt>: Upper bound of the minimization
    #
    def initialize(f, initial_guess, lower_bound, upper_bound)
      super(f, initial_guess.clone, lower_bound, upper_bound)
      @relative_threshold = RELATIVE_THRESHOLD_DEFAULT
      @absolute_threshold = ABSOLUTE_THRESHOLD_DEFAULT
    end

    # Obtain new point and direction from the previous point,
    # previous direction and a parameter value
    # == Parameters:
    # * <tt>point</tt>: Previous point
    # * <tt>direction</tt>: Previous direction
    # * <tt>minimum</tt>: parameter value
    #
    def new_point_and_direction(point, direction, minimum)
      n         = point.length
      new_point = Array.new(n)
      new_dir   = Array.new(n)
      0.upto(n - 1) do |i|
        new_dir[i]   = direction[i] * minimum
        new_point[i] = point[i] + new_dir[i]
      end
      return {:point => new_point, :dir => new_dir}
    end

    # Iterate Powell's minimizer
    def minimize
      @iterations += 1

      # set initial configurations
      if(@iterations <= 1)
        guess = @start
        @n     = guess.length
        # initialize all to 0
        @direc = Array.new(@n) { Array.new(@n) {0} }
        0.upto(@n - 1) do |i|
          # set diagonal values to 1
          @direc[i][i] = 1
        end

        @x     = guess
        @f_val = f(@x)
        @x1    = @x.clone
      end

      fx        = @f_val
      fx2       = 0
      delta     = 0
      big_ind   = 0
      alpha_min = 0

      0.upto(@n - 1) do |i|
        direction = @direc[i].clone
        fx2       = @f_val
        # Find line minimum
        minimum   = brent_search(@x, direction)
        @f_val    = minimum[:f_val]
        alpha_min = minimum[:alpha_min]
        # Obtain new point and direction
        new_pnd   = new_point_and_direction(@x, direction, alpha_min)
        new_point = new_pnd[:point]
        new_dir   = new_pnd[:dir]
        @x         = new_point

        if ((fx2 - @f_val) > delta) 
          delta   = fx2 - @f_val
          big_ind = i
        end
      end

      # convergence check
      @converging = !(2 * (fx - @f_val) <= (@relative_threshold * (fx.abs + @f_val.abs) + @absolute_threshold))

      # storing results
      if((@f_val < fx))
        @x_minimum = @x
        @f_minimum = @f_val
      else
        @x_minimum = @x1
        @f_minimum = fx
      end

      direction  = Array.new(@n)
      x2         = Array.new(@n)
      0.upto(@n -1) do |i|
        direction[i]  = @x[i] - @x1[i]
        x2[i]         = 2 * @x[i] - @x1[i]
      end

      @x1  = @x.clone
      fx2 = f(x2)

      if (fx > fx2)
        t    = 2 * (fx + fx2 - 2 * @f_val)
        temp = fx - @f_val - delta
        t   *= temp * temp
        temp = fx - fx2
        t   -= delta * temp * temp

        if (t < 0.0)
          minimum   = brent_search(@x, direction)
          @f_val     = minimum[:f_val]
          alpha_min = minimum[:alpha_min]
          # Obtain new point and direction
          new_pnd   = new_point_and_direction(@x, direction, alpha_min)
          new_point = new_pnd[:point]
          new_dir   = new_pnd[:dir]
          @x         = new_point

          last_ind        = @n - 1
          @direc[big_ind]  = @direc[last_ind]
          @direc[last_ind] = new_dir
        end
      end
    end

  end
end
