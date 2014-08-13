# = brent_root_finder.rb -
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
# Nelder Mead Algorithm for Multidimensional minimization

module Minimization

  # Brent's root finding method.  
  # == Usage
  #   f   = lambda {|x| x**2}
  #   root_finder = Minimization::BrentRootFinder.new(100000)
  #   root_finder.find_root(-1000,1000, f)
  #
  class BrentRootFinder
    attr_accessor :max_iterations
    MAX_ITERATIONS_DEFAULT = 10e6
    EPSILON                = 10e-10

    def initialize(max_iterations=nil)
      @iterations = 0
      if (@max_iterations.nil?)
        @max_iterations = MAX_ITERATIONS_DEFAULT
      end
    end

    def f(x)
      return @f.call(x)
    end

    def find_root(lower_bound, upper_bound, f)
      @f = f
      lower  = lower_bound
      f_upper = f(lower_bound)
      upper  = upper_bound
      f_lower = f(upper_bound)
      c  = lower
      fc = f_upper
      d  = upper - lower
      e  = d

      absolute_accuracy = EPSILON
      relative_accuracy = EPSILON

      loop do
        @iterations += 1
        if (fc.abs < f_lower.abs)
          lower  = upper
          upper  = c
          c  = lower
          f_upper = f_lower
          f_lower = fc
          fc = f_upper
        end

        tolerance = 2 * relative_accuracy * upper.abs + absolute_accuracy
        m   = 0.5 * (c - upper)

        if (m.abs <= tolerance or f_lower.abs < EPSILON or @iterations > @max_iterations)
          return upper
        end
        if (e.abs < tolerance or f_upper.abs <= f_lower.abs)
          # use bisection
          d = m
          e = d
        else 
          # use inverse cubic interpolation
          s = f_lower / f_upper
          if (lower == c)
            p = 2 * m * s
            q = 1 - s
          else
            q = f_upper / fc
            r = f_lower / fc
            p = s * (2 * m * q * (q - r) - (upper - lower) * (r - 1))
            q = (q - 1) * (r - 1) * (s - 1)
          end
          if (p > 0)
            q = -q
          else 
            p = -p
          end
          s = e
          e = d
          if (p >= 1.5 * m * q - (tolerance * q).abs or p >= (0.5 * s * q).abs)
            # interpolation failed, fall back to bisection
            d = m
            e = d
          else
            d = p / q
          end
        end
        # Update the best estimate of the root and bounds on each iteration
        lower  = upper
        f_upper = f_lower

        if (d.abs > tolerance)
          upper += d
        elsif (m > 0)
          upper += tolerance
        else
          upper -= tolerance
        end
        f_lower = f(upper)
        if ((f_lower > 0 and fc > 0) or (f_lower <= 0 and fc <= 0))
          c  = lower
          fc = f_upper
          d  = upper - lower
          e  = d
        end
      end
    end
  end
end
