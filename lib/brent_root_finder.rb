module Minimization

  class BrentRootFinder

    attr_accessor :max_iterations

    MAX_ITERATIONS_DEFAULT = 10000
    EPSILON                = 10e-10

    def initialize(max_iterations)
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
          d = m
          e = d
        else 
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
            d = m
            e = d
          else
            d = p / q
          end
        end
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
