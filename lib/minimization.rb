# = minimization.rb -
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
# Algorithms for unidimensional minimization
require 'text-table'
module Minimization
  VERSION="0.2.1"
  FailedIteration=Class.new(Exception)
  # Base class for unidimensional minimizers
  class Unidimensional
    # Default value for error on f(x)
    EPSILON=1e-6
    # Default number of maximum iterations
    MAX_ITERATIONS=100
    # Minimum value for x
    attr_reader :x_minimum
    # Minimum value for f(x)
    attr_reader :f_minimum
    # Log of iterations. Should be an array
    attr_reader :log
    # Name of fields of log
    attr_reader :log_header
    # Absolute error on x
    attr_accessor :epsilon
    # Expected value. Fast minimum finding if set
    attr_reader :expected
    # Numbers of iterations
    attr_reader :iterations
    # Create a new minimizer
    def initialize(lower, upper, proc)
      raise "first argument  should be lower than second" if lower>=upper
      @lower=lower
      @upper=upper
      @proc=proc
      golden = 0.3819660;
      @expected = @lower + golden * (@upper - @lower);
      @max_iteration=MAX_ITERATIONS
      @epsilon=EPSILON
      @iterations=0
      @log=[]
      @log_header=%w{I xl xh f(xl) f(xh) dx df(x)}
    end
    # Set expected value
    def expected=(v)
      @expected=v
    end
    def log_summary
      @log.join("\n")
    end
    # Convenience method to minimize
    # == Parameters:
    # * <tt>lower</tt>: Lower possible value
    # * <tt>upper</tt>: Higher possible value
    # * <tt>expected</tt>: Optional expected value. Faster the search is near correct value.
    # * <tt>&block</tt>: Block with function to minimize
    # == Usage:
    #   minimizer=Minimization::GoldenSection.minimize(-1000, 1000) {|x|
    #             x**2 }
    # 
    def self.minimize(lower,upper,expected=nil,&block)
      minimizer=new(lower,upper,block)
      minimizer.expected=expected unless expected.nil?
      raise FailedIteration unless minimizer.iterate
      minimizer
    end
    # Iterate to find the minimum
    def iterate
      raise "You should implement this"
    end
    def f(x)
      @proc.call(x)
    end
  end
  # Classic Newton-Raphson minimization method.  
  # Requires first and second derivative
  # == Usage
  #   f   = lambda {|x| x**2}
  #   fd  = lambda {|x| 2x}
  #   fdd = lambda {|x| 2}
  #   min = Minimization::NewtonRaphson.new(-1000,1000, f,fd,fdd)
  #   min.iterate
  #   min.x_minimum
  #   min.f_minimum
  #   
  class NewtonRaphson < Unidimensional
    # == Parameters:
    # * <tt>lower</tt>: Lower possible value
    # * <tt>upper</tt>: Higher possible value
    # * <tt>proc</tt>: Original function
    # * <tt>proc_1d</tt>: First derivative
    # * <tt>proc_2d</tt>: Second derivative
    # 
    def initialize(lower, upper, proc, proc_1d, proc_2d)
      super(lower,upper,proc)
      @proc_1d=proc_1d
      @proc_2d=proc_2d
    end
    # Raises an error
    def self.minimize(*args)
      raise "You should use #new and #iterate"
    end
    def iterate
      # First
      x_prev=@lower
      x=@expected
      failed=true
      k=0
      while (x-x_prev).abs > @epsilon and k<@max_iteration
        k+=1
        x_prev=x
        x=x-(@proc_1d.call(x).quo(@proc_2d.call(x)))
        f_prev=f(x_prev)
        f=f(x)
        x_min,x_max=[x,x_prev].min, [x,x_prev].max 
        f_min,f_max=[f,f_prev].min, [f,f_prev].max 
        @log << [k, x_min, x_max, f_min, f_max, (x_prev-x).abs, (f-f_prev).abs]
      end
      raise FailedIteration, "Not converged" if k>=@max_iteration
      @x_minimum = x;
      @f_minimum = f(x);
    end
  end
  # = Golden Section Minimizer.
  # Basic minimization algorithm. Slow, but robust.
  # See Unidimensional for methods.
  # == Usage.
  #  require 'minimization'
  #  min=Minimization::GoldenSection.new(-1000,20000  , proc {|x| (x+1)**2}
  #  min.expected=1.5  # Expected value
  #  min.iterate
  #  min.x_minimum
  #  min.f_minimum
  #  min.log
  class GoldenSection < Unidimensional
    # Start the iteration
    def iterate
      ax=@lower
      bx=@expected
      cx=@upper
      c = (3-Math::sqrt(5)).quo(2);
      r = 1-c;

      x0 = ax;
      x3 = cx;
      if ((cx-bx).abs > (bx-ax).abs)
        x1 = bx;
        x2 = bx + c*(cx-bx);
      else
        x2 = bx;
        x1 = bx - c*(bx-ax);
      end
      f1 = f(x1);
      f2 = f(x2);

      k = 1;



      while (x3-x0).abs > @epsilon and k<@max_iteration
        if f2 < f1
          x0 = x1;
          x1 = x2;
          x2 = r*x1 + c*x3;   # x2 = x1+c*(x3-x1)
          f1 = f2;
          f2 = f(x2);
        else
          x3 = x2;
          x2 = x1;
          x1 = r*x2 + c*x0;   # x1 = x2+c*(x0-x2)
          f2 = f1;
          f1 = f(x1);
        end
        @log << [k, x3,x0, f1,f2,(x3-x0).abs, (f1-f2).abs]
        
        k +=1;
      end

      if f1 < f2
        @x_minimum = x1;
        @f_minimum = f1;
      else
        @x_minimum = x2;
        @f_minimum = f2;
      end
      true
    end

  end

  # Direct port of Brent algorithm found on GSL.
  # See Unidimensional for methods.
  # == Usage
  #  min=Minimization::Brent.new(-1000,20000  , proc {|x| (x+1)**2}
  #  min.expected=1.5  # Expected value
  #  min.iterate
  #  min.x_minimum
  #  min.f_minimum
  #  min.log

  class Brent < Unidimensional
    GSL_SQRT_DBL_EPSILON=1.4901161193847656e-08
    def initialize(lower,upper, proc)
      super

      @do_bracketing=true

      # Init

      golden = 0.3819660;      #golden = (3 - sqrt(5))/2

      v = @lower + golden * (@upper - @lower);
      w = v;

      @x_minimum = v ;
      @f_minimum = f(v) ;
      @x_lower=@lower
      @x_upper=@upper
      @f_lower = f(@lower) ;
      @f_upper = f(@lower) ;

      @v = v;
      @w = w;

      @d = 0;
      @e = 0;
      @f_v=f(v)
      @f_w=@f_v
    end

    def expected=(v)
      @x_minimum=v
      @f_minimum=f(v)
      @do_bracketing=false
    end
    
    def bracketing
      eval_max=10
      f_left = @f_lower;
      f_right = @f_upper;
      x_left = @x_lower;
      x_right= @x_upper;
      golden = 0.3819660;      # golden = (3 - sqrt(5))/2 */
      nb_eval=0

      if (f_right >= f_left)
        x_center = (x_right - x_left) * golden + x_left;
        nb_eval+=1;
        f_center=f(x_center)
      else
        x_center = x_right ;
        f_center = f_right ;
        x_right = (x_center - x_left).quo(golden) + x_left;
        nb_eval+=1;
        f_right=f(x_right);
      end


      begin
        @log << ["B#{nb_eval}", x_left, x_right, f_left, f_right, (x_left-x_right).abs, (f_left-f_right).abs]
        if (f_center < f_left )
          if (f_center < f_right)
            @x_lower = x_left;
            @x_upper = x_right;
            @x_minimum = x_center;
            @f_lower = f_left;
            @f_upper = f_right;
            @f_minimum = f_center;
            return true;
          elsif (f_center > f_right)
            x_left = x_center;
            f_left = f_center;
            x_center = x_right;
            f_center = f_right;
            x_right = (x_center - x_left).quo(golden) + x_left;
            nb_eval+=1;
            f_right=f(x_right);
          else # f_center == f_right */
            x_right = x_center;
            f_right = f_center;
            x_center = (x_right - x_left).quo(golden) + x_left;
            nb_eval+=1;
            f_center=f(x_center);
          end
        else # f_center >= f_left */
          x_right = x_center;
          f_right = f_center;
          x_center = (x_right - x_left) * golden + x_left;
          nb_eval+=1;
          f_center=f(x_center);
        end
      end while ((nb_eval < eval_max) and
      ((x_right - x_left) > GSL_SQRT_DBL_EPSILON * ( (x_right + x_left) * 0.5 ) + GSL_SQRT_DBL_EPSILON))
      @x_lower = x_left;
      @x_upper = x_right;
      @x_minimum = x_center;
      @f_lower = f_left;
      @f_upper = f_right;
      @f_minimum = f_center;
      return false;

    end
    # Start the minimization process
    # If you want to control manually the process, use brent_iterate
    def iterate
      k=0
      bracketing if @do_bracketing
      while k<@max_iteration and (@x_lower-@x_upper).abs>@epsilon
        k+=1
        result=brent_iterate
        raise FailedIteration,"Error on iteration" if !result
        begin 
          @log << [k, @x_lower, @x_upper, @f_lower, @f_upper, (@x_lower-@x_upper).abs, (@f_lower-@f_upper).abs]
        rescue =>@e
          @log << [k, @e.to_s,nil,nil,nil,nil,nil]
        end
      end
      @iterations=k
      return true
    end
    # Generate one iteration.
    def brent_iterate
      x_left = @x_lower;
      x_right = @x_upper;

      z = @x_minimum;
      d = @e;
      e = @d;
      v = @v;
      w = @w;
      f_v = @f_v;
      f_w = @f_w;
      f_z = @f_minimum;

      golden = 0.3819660;      # golden = (3 - sqrt(5))/2 */

      w_lower = (z - x_left)
      w_upper = (x_right - z)

      tolerance =  GSL_SQRT_DBL_EPSILON * z.abs

      midpoint = 0.5 * (x_left + x_right)
      _p,q,r=0,0,0
      if (e.abs > tolerance)

        # fit parabola */

        r = (z - w) * (f_z - f_v);
        q = (z - v) * (f_z - f_w);
        _p = (z - v) * q - (z - w) * r;
        q = 2 * (q - r);

        if (q > 0)
          _p = -_p
        else
          q = -q;
        end
        r = e;
        e = d;
      end

      if (_p.abs < (0.5 * q * r).abs and _p < q * w_lower and _p < q * w_upper)
        t2 = 2 * tolerance ;

        d = _p.quo(q);
        u = z + d;

        if ((u - x_left) < t2 or (x_right - u) < t2)
          d = (z < midpoint) ? tolerance : -tolerance ;
        end
      else

        e = (z < midpoint) ? x_right - z : -(z - x_left) ;
        d = golden * e;
      end

      if ( d.abs >= tolerance)
        u = z + d;
      else
        u = z + ((d > 0) ? tolerance : -tolerance) ;
      end

      @e = e;
      @d = d;

      f_u=f(u)

      if (f_u <= f_z)
        if (u < z)
          @x_upper = z;
          @f_upper = f_z;
        else
          @x_lower = z;
          @f_lower = f_z;
        end
        @v = w;
        @f_v = f_w;
        @w = z;
        @f_w = f_z;
        @x_minimum = u;
        @f_minimum = f_u;
        return true;
      else
        if (u < z)
          @x_lower = u;
          @f_lower = f_u;
          return true;
        else
          @x_upper = u;
          @f_upper = f_u;
          return true;
        end

        if (f_u <= f_w or w == z)
          @v = w;
          @f_v = f_w;
          @w = u;
          @f_w = f_u;
          return true;
        elsif f_u <= f_v or v == z or v == w
          @v = u;
          @f_v = f_u;
          return true;
        end

      end
      return false

    end
  end

## starting

class PointValuePair
    attr_reader :point
    attr_reader :value
    def initialize(point, value)
        @point = point
        @value = value
    end
  end

  class Multidimensional
    # Default value for error on f(x)
    EPSILON=1e-6
    # Default number of maximum iterations
    MAX_ITERATIONS=100
    # Minimum value for x
    attr_reader :x_minimum
    # Minimum value for f(x)
    attr_reader :f_minimum
    # Log of iterations. Should be an array
    attr_reader :log
    # Name of fields of log
    attr_reader :log_header
    # Absolute error on x
    attr_accessor :epsilon
    # Expected value. Fast minimum finding if set
    attr_reader :expected
    # Numbers of iterations
    attr_reader :iterations
    attr_reader :start_point
    attr_reader :startConfiguration
    # Create a new minimizer
    def initialize(lower, upper, dimensions, proc)
      raise "first argument  should be lower than second" if lower>=upper
      @lower=lower
      @upper=upper
      @proc=proc
      golden = 0.3819660;
      @expected = @lower + golden * (@upper - @lower);
      @max_iteration=MAX_ITERATIONS
      @epsilon=EPSILON
      @iterations=0
      @log=[]
      @log_header=%w{I xl xh f(xl) f(xh) dx df(x)}
      @startConfiguration = Array.new(dimensions)
      0.upto(dimensions-1) do |i|
        @startConfiguration[i] = Array.new(dimensions)
        0.upto(dimensions-1) do |j|
          @startConfiguration[i][j] = 0.0
        end
      end
    end
    # Set expected value
    def expected=(v)
      @expected=v
    end
    def log_summary
      @log.join("\n")
    end
      
    def self.minimize(lower,upper,expected=nil,&block)
      minimizer=new(lower,upper,block)
      minimizer.expected=expected unless expected.nil?
      raise FailedIteration unless minimizer.iterate
      minimizer
    end
    # Iterate to find the minimum
    def iterate
      raise "You should implement this"
    end
    def f(x)
      @proc.call(x)
    end
  end

  class NelderMead < Multidimensional
    # == Parameters:
    # * <tt>lower</tt>: Lower possible value
    # * <tt>upper</tt>: Higher possible value
    # * <tt>proc</tt>: Original function


    def initialize(lower, upper, dimensions, start_point, proc)
      super(lower, upper, dimensions, proc)
      @rho         = 1    # Reflection coefficient
      @khi         = 2    # Expansion coefficient
      @gamma       = 0.5  # Contraction coefficient
      @sigma       = 0.5  # Shrinkage coefficient
      @dimensions  = dimensions
      @start_point = start_point
    end

    # Raises an error
    def self.minimize(*args)
      raise "You should use #new and #iterate"
    end

    def build_Simplex(start_point)
        # set first vertex
        n          = start_point.length
        simplex    = Array.new(n+1)
        simplex[0] = PointValuePair.new(start_point, Float::NAN)

        # set remaining vertices
        0.upto(n-1) do |i|
          conf   = startConfiguration[i]
          vertex = Array.new(n)
          0.upto(n-1) do |k|
            vertex[k] = start_point[k] + conf[k]
          end
          simplex[i + 1] = PointValuePair.new(vertex, Float::NAN)
        end 
        return simplex
    end

    def replace_worst_point(point_value_pair)
      0.upto(simplex.length - 2) do |i|
        if (point_value_pair_compare(simplex[i], point_value_pair) > 0)
          tmp              = simplex[i]
          simplex[i]       = point_value_pair
          point_value_pair = tmp
        end
      end
      simplex[simplex.length - 1] = point_value_pair
    end

    def point_value_pair_compare(v1, v2)
      if v1.value > v2.value
        return 1
      elsif v1.value == v2.value
        return 0
      else
        return (-1)
      end
    end

    def evaluate_simplex()
      # evaluate the objective function at all non-evaluated simplex points
      0.upto(simplex.length -1) do |i|
        vertex = simplex[i]
        point  = vertex.point
        if vertex.value.nan?
          simplex[i] = PointValuePair.new(point, f(point))
        end
      end
      # sort the simplex from best to worst
      simplex.sort{ |x1, x2| x1.value <=> x2.value }
    end

    def iterate
      k = 1
      n = 2
      n = @dimensions
      simplex = Array.new(n+1)   # array of PointValuePair. init simplex by
        
      build_Simplex(@start_point)

      while k < @max_iteration   # and check with @epsilon
        best        = simplex[0]
        second_best = simplex[n-1]
        worst       = simplex[n]
        xWorst      = worst

        centroid = Array.new(n)
        0.upto(n-1) do |i|
          centroid[i] = 0.0
        end

        # compute the centroid of the best vertices
        # (dismissing the worst point at index n)
        0.upto(n-1) do |i|
          x = simplex[i]
          0.upto(n-1) do |j|
            centroid[j] += x[j]
          end
        end
        scaling = 1.0/n
        0.upto(n-1) do |j|
          centroid[j] *= scaling;
        end

        # compute the reflection point
        xR = Array.new(n)
        0.upto(n-1) do |i|
          xR[i] = 0.0
        end
        0.upto(n-1) do |j|
          xR[j] = centroid[j] + @rho * (centroid[j] - xWorst[j])
        end
        
        reflected = PointValuePair.new(xR, f(xR))

        if(point_value_pair_compare(best, reflected) <=0 and 
          point_value_pair_compare(reflected, second_best) < 0)
          replace_worst_point(reflected, comparator)

        elsif(point_value_pair_compare(reflected, best) < 0)
          xE = Array.new(n)
          0.upto(n-1) do |i|
              xE[j] = centroid[j] + khi * (xR[j] - centroid[j])
          end
          expanded = PointValuePair(xE, f(xE))

          if (point_value_pair_compare(expanded, reflected) < 0)
              # accept the expansion point
              replace_worst_point(expanded, comparator)
          else
              # accept the reflected point
              replace_worst_point(reflected, comparator)
          end

        else 
                    
          if comparator.compare(reflected, worst) < 0
            # perform an outside contraction
            xC = Array.new(n)
            0.upto(n-1) do |j|
                xC[j] = centroid[j] + gamma * (xR[j] - centroid[j])
            end
            out_contracted = PointValuePair.new(xC, f(xC))
            if point_value_pair_compare(out_contracted, reflected) <= 0
                # accept the contraction point
                replace_worst_point(out_contracted, comparator)
                return
            end

          else
            # perform an inside contraction
            xC = Array.new(n)
            0.upto(n-1) do |j|
                xC[j] = centroid[j] - gamma * (centroid[j] - xWorst[j])
            end
            in_contracted = PointValuePair.new(xC, f(xC))
            if comparator.compare(in_contracted, worst) < 0
                # accept the contraction point
                replace_worst_point(in_contracted, comparator)
                return
            end

          end

          # perform a shrink
          smallest = simplex[0].point
          1.upto(simplex.length -1) do |i|
              x = simplex[i].point
              0.upto(n-1) do |j|
                  x[j] = smallest[j] + sigma * (x[j] - smallest[j])
              end
              simplex[i] = PointValuePair.new(x, Float::NAN)
          end
          evaluate_simplex(comparator)

        end
        k += 1
      end
    end
  end
end