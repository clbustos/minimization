# = Nelder_Mead.rb -
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
# Math library's NelderMead.java file. Therefore this file is under
# Apache License Version 2.
#
# Nelder Mead Algorithm for Multidimensional minimization
module Minimization
  # class which holds the point,value pair
  class RealPointValuePair
    attr_reader   :value
    attr_accessor :value
    attr_reader   :point

    # == Parameters:
    # * <tt>point</tt>: Coordinates of the point
    # * <tt>value</tt>: Function value at the point
    #
    def initialize(point, value)
      @point = point.clone
      @value  = value
    end

    # returns a copy of the point
    def get_point_clone
      return @point.clone
    end
  end

  class DirectSearchMinimizer
    EPSILON         = 1e-6
    MAX_ITERATIONS  = 1000000
    MAX_EVALUATIONS = 1000000
    SAFE_MIN        = 0x1e-1022
    attr_reader :x_minimum
    attr_reader :f_minimum
    attr_reader :epsilon

    def initialize(f, start_point, iterate_simplex_ref)
      @epsilon             = EPSILON
      @safemin             = SAFE_MIN
      # Default number of maximum iterations
      @max_iterations      = MAX_ITERATIONS
      # Default number of maximum iterations
      @max_evaluations     = MAX_EVALUATIONS
      # proc which iterates the simplex
      @iterate_simplex_ref = iterate_simplex_ref
      @relative_threshold  = 100 * @epsilon
      @absolute_threshold  = 100 * @safemin
      @x_minimum           = nil
      @f_minimum           = nil
      @f = f

      # create and initializ start configurations
      if @start_configuration == nil
        # sets the start configuration point as unit
        self.start_configuration = Array.new(start_point.length) { 1.0 }
      end

      @iterations  = 0
      @evaluations = 0
      # create the simplex for the first time
      build_simplex(start_point)
      evaluate_simplex
    end

    def f(x)
      @evaluations += 1
      raise "evaluation error!" if (@evaluations > @max_evaluations)
      return @f.call(x)
    end

    def iterate_simplex
      return iterate_simplex_ref.call
    end

    # increment iteration counter by 1
    def increment_iterations_counter
      @iterations += 1
      raise "iteration limit reached" if @iterations > @max_iterations
    end

    # compares 2 RealPointValuePair points
    def compare(v1, v2)
      if v1.value == v2.value
        return 0
      elsif v1.value > v2.value
        return 1
      else
        return -1
      end
    end

    # checks whether the function is converging
    def converged
      # check the convergence of a point of the simplex by it's current 
      # and previous values
      def point_converged(previous, current)
        pre        = previous.value
        curr       = current.value
        diff       = (pre - curr).abs
        size       = [pre.abs, curr.abs].max
        return (diff <= (size * @relative_threshold)) || (diff <= @absolute_threshold)
      end

      # checks whether all the points of simplex are converging
      if @iterations > 0
        converged = true
        0.upto(@simplex.length-1) do |i|
          converged &= point_converged(@previous[i], @simplex[i])
        end
        return converged
      end

      # if no iterations were done, convergence undefined
      return false
    end

    # only the relative position of the n vertices with respect
    # to the first one are stored
    def start_configuration=(steps)
      n = steps.length
      @start_configuration = Array.new(n) { Array.new(n) }
      0.upto(n-1) do |i|
        vertex_i = @start_configuration[i]
        0.upto(i) do |j|
          raise "equals vertices #{j} and #{j+1} in simplex configuration" if steps[j] == 0.0
          0.upto(j+1) do |k|
            vertex_i[k] = steps[k]
          end
        end
      end
    end

    # Build an initial simplex
    # == Parameters:
    # * <tt>start_point</tt>: starting point of the minimization search
    #
    def build_simplex(start_point)
      n = start_point.length
      raise "dimension mismatch" if n != @start_configuration.length
      # set first vertex
      @simplex = Array.new(n+1)
      @simplex[0] = RealPointValuePair.new(start_point, Float::NAN)

      # set remaining vertices
      0.upto(n-1) do |i|
        conf_i   = @start_configuration[i]
        vertex_i = Array.new(n)
        0.upto(n-1) do |k|
          vertex_i[k] = start_point[k] + conf_i[k]
        end
        @simplex[i + 1] = RealPointValuePair.new(vertex_i, Float::NAN)
      end
    end

    # Evaluate all the non-evaluated points of the simplex
    def evaluate_simplex
      # evaluate the objective function at all non-evaluated simplex points
      0.upto(@simplex.length-1) do |i|
        vertex = @simplex[i]
        point = vertex.point
        if vertex.value.nan?
          @simplex[i] = RealPointValuePair.new(point, f(point))
        end
      end
      # sort the simplex from best to worst
      @simplex.sort!{ |x1, x2| x1.value <=> x2.value }
    end

    # Replace the worst point of the simplex by a new point
    # == Parameters:
    # * <tt>point_value_pair</tt>: point to insert
    #
    def replace_worst_point(point_value_pair)
      n = @simplex.length - 1
      0.upto(n-1) do |i|
        if (compare(@simplex[i], point_value_pair) > 0)
          point_value_pair, @simplex[i] = @simplex[i], point_value_pair
        end
      end
      @simplex[n] = point_value_pair
    end

    # iterate one step
    def iterate
      # set previous simplex as the current simplex
      @previous = Array.new(@simplex.length)
      0.upto(@simplex.length - 1) do |i|
        point = @simplex[i].point                                # clone require?
        @previous[i] = RealPointValuePair.new(point, f(point))
      end
      # iterate simplex
      iterate_simplex
      # set results
      @x_minimum = @simplex[0].point
      @f_minimum = @simplex[0].value
    end
  end

    # = Nelder Mead Minimizer.
    # A multidimensional minimization methods.
    # == Usage.
    #  require 'minimization'
    #  min=Minimization::NelderMead.new(proc {|x| (x[0] - 2)**2}, [1, 2]}
    #  min.iterate
    #  min.x_minimum
    #  min.f_minimum
    #
  class NelderMead < DirectSearchMinimizer
    def initialize(f, start_point)
      # Reflection coefficient
      @rho   = 1.0
      # Expansion coefficient
      @khi   = 2.0
      # Contraction coefficient
      @gamma = 0.5
      # Shrinkage coefficient
      @sigma = 0.5
      super(f, start_point, proc{iterate_simplex})
    end
    
    def iterate_simplex
      increment_iterations_counter
      n = @simplex.length - 1
      # the simplex has n+1 point if dimension is n
      best       = @simplex[0]
      secondBest = @simplex[n-1]
      worst      = @simplex[n]
      x_worst    = worst.point
      centroid = Array.new(n, 0)
      # compute the centroid of the best vertices
      # (dismissing the worst point at index n)
      0.upto(n-1) do |i|
        x = @simplex[i].point
        0.upto(n-1) do |j|
          centroid[j] += x[j]
        end
      end
      scaling = 1.0 / n
      0.upto(n-1) do |j|
        centroid[j] *= scaling
      end
      xr = Array.new(n)
      # compute the reflection point
      0.upto(n-1) do |j|
        xr[j] = centroid[j] + @rho * (centroid[j] - x_worst[j])
      end
      reflected = RealPointValuePair.new(xr, f(xr))
      if ((compare(best, reflected) <= 0) && (compare(reflected, secondBest) < 0))
        # accept the reflected point
        replace_worst_point(reflected)
      elsif (compare(reflected, best) < 0)
        xe = Array.new(n)
        # compute the expansion point
        0.upto(n-1) do |j|
          xe[j] = centroid[j] + @khi * (xr[j] - centroid[j])
        end
        expanded = RealPointValuePair.new(xe, f(xe))
        if (compare(expanded, reflected) < 0)
          # accept the expansion point
          replace_worst_point(expanded)
        else
          # accept the reflected point
          replace_worst_point(reflected)
        end
      else
        if (compare(reflected, worst) < 0)
          xc = Array.new(n)
          # perform an outside contraction
          0.upto(n-1) do |j|
            xc[j] = centroid[j] + @gamma * (xr[j] - centroid[j])
          end
          out_contracted = RealPointValuePair.new(xc, f(xc))
          if (compare(out_contracted, reflected) <= 0)
            # accept the contraction point
            replace_worst_point(out_contracted)
            return
          end
        else
          xc = Array.new(n)
          # perform an inside contraction
          0.upto(n-1) do |j|
            xc[j] = centroid[j] - @gamma * (centroid[j] - x_worst[j])
          end
          in_contracted = RealPointValuePair.new(xc, f(xc))

          if (compare(in_contracted, worst) < 0)
            # accept the contraction point
            replace_worst_point(in_contracted)
            return
          end
        end
        # perform a shrink
        x_smallest = @simplex[0].point
        0.upto(@simplex.length-1) do |i|
          x = @simplex[i].get_point_clone
          0.upto(n-1) do |j|
            x[j] = x_smallest[j] + @sigma * (x[j] - x_smallest[j])
          end
          @simplex[i] = RealPointValuePair.new(x, Float::NAN)
        end
        evaluate_simplex
      end
    end
  end
end

f = proc {|x| (x[0] - 20)**2 + (x[1] - 30)**2}
min = Minimization::NelderMead.new(f,[1, 2])
until(min.converged)
  min.iterate
end
puts "results :  #{min.x_minimum}     #{min.f_minimum}"
