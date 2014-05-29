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

class RealPointValuePair
    attr_reader   :value
    attr_accessor :value
    attr_reader   :point
    def initialize(point, value)
        @point = point.clone
        @value  = value
    end

    def get_point()
        return @point.clone
    end
end

class DirectSearchOptimizer

    def initialize(iterate_simplex_ref)
        @EPSILON           = 1e-6
        @SAFEMIN           = 0x1e-1022
        @max_iterations     = 1000000
        @max_evaluations    = 1000000
        @iterate_simplex_ref = iterate_simplex_ref
        @relative_threshold = 100 * @EPSILON
        @absolute_threshold = 100 * @SAFEMIN
    end

    def converged(previous, current)
        pre        = previous.value
        curr       = current.value
        diff       = (pre - curr).abs
        size       = [pre.abs, curr.abs].max
        return (diff <= (size * @relative_threshold)) || (diff <= @absolute_threshold)
    end

    def f(x)
            return (x[0]-2)**2
    end

    def iterate_simplex()
        return iterate_simplex_ref.call
    end

    def set_start_configuration(steps)
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

    def compare(v1, v2)
        if v1.value == v2.value
            return 0
        elsif v1.value > v2.value
            return 1
        else
            return -1
        end
    end

    def optimize(start_point)
        if @start_configuration == nil
            unit = Array.new(start_point.length) { 1.0 }
            set_start_configuration(unit)
        end

        @iterations  = 0
        @evaluations = 0
        build_simplex(start_point)
        evaluate_simplex()

        @previous = Array.new(@simplex.length)
        loop do
            if @iterations > 0
                converged = true
                0.upto(@simplex.length-1) do |i|
                    converged &= converged(@previous[i], @simplex[i])
                end
                if (converged)
                    return @simplex[0]
                end
            end

            @previous = @simplex[0..(@previous.length-1)]      # check again for requirement
            iterate_simplex()
        end
    end

    def increment_iterations_counter()
        @iterations += 1
        raise "iteration limit reached" if @iterations > @max_iterations
    end

    def evaluate(x)
         @evaluations += 1
        raise "evaluation error!" if (@evaluations > @max_evaluations)
        return f(x)
    end

    def build_simplex(start_point)
        n = start_point.length
        raise "dimension mismatch" if n != @start_configuration.length

        @simplex = Array.new(n+1)
        @simplex[0] = RealPointValuePair.new(start_point, Float::NAN)

        0.upto(n-1) do |i|
            conf_i   = @start_configuration[i]
            vertex_i = Array.new(n)
            0.upto(n-1) do |k|
                vertex_i[k] = start_point[k] + conf_i[k]
            end
            @simplex[i + 1] = RealPointValuePair.new(vertex_i, Float::NAN)
        end

    end

     def evaluate_simplex()
        0.upto(@simplex.length-1) do |i|
            vertex = @simplex[i]
            point = vertex.point
            if vertex.value.nan?
                @simplex[i] = RealPointValuePair.new(point, evaluate(point))
            end
        end
        @simplex.sort!{ |x1, x2| x1.value <=> x2.value }
        puts "sorted"
        0.upto(@simplex.length-1) do |i|
            puts "#{@simplex[i].point}   #{@simplex[i].value}"
        end
    end

    def replace_worst_point(point_value_pair)
        n = @simplex.length - 1
        0.upto(n-1) do |i|
            if (compare(@simplex[i], point_value_pair) > 0)
                tmp            = @simplex[i]
                @simplex[i]     = point_value_pair
                point_value_pair = tmp
            end
        end
        @simplex[n] = point_value_pair
    end
end

class NelderMead < DirectSearchOptimizer

    def initialize()
        super(proc{iterate_simplex})
        @rho   = 1.0;
        @khi   = 2.0;
        @gamma = 0.5;
        @sigma = 0.5;
    end

    def iterate_simplex()
        increment_iterations_counter()
        n = @simplex.length - 1
        best       = @simplex[0]
        secondBest = @simplex[n-1]
        worst      = @simplex[n]
        x_worst     = worst.point

        centroid = Array.new(n, 0)

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
        0.upto(n-1) do |j|
            xr[j] = centroid[j] + @rho * (centroid[j] - x_worst[j])
        end
        reflected = RealPointValuePair.new(xr, evaluate(xr))

        if ((compare(best, reflected) <= 0) && (compare(reflected, secondBest) < 0))
            replace_worst_point(reflected)

        elsif (compare(reflected, best) < 0)
            xe = Array.new(n)
            0.upto(n-1) do |j|
                xe[j] = centroid[j] + @khi * (xr[j] - centroid[j])
            end
            expanded = RealPointValuePair.new(xe, evaluate(xe))

            if (compare(expanded, reflected) < 0)
                replace_worst_point(expanded)
            else
                replace_worst_point(reflected)
            end

        else
            if (compare(reflected, worst) < 0)
                xc = Array.new(n)
                0.upto(n-1) do |j|
                    xc[j] = centroid[j] + @gamma * (xr[j] - centroid[j])
                end
                out_contracted = RealPointValuePair.new(xc, evaluate(xc))

                if (compare(out_contracted, reflected) <= 0)
                    replace_worst_point(out_contracted)
                    return
                end

            else
                xc = Array.new(n)
                0.upto(n-1) do |j|
                    xc[j] = centroid[j] - @gamma * (centroid[j] - x_worst[j])
                end
                in_contracted = RealPointValuePair.new(xc, evaluate(xc))

                if (compare(in_contracted, worst) < 0)
                    replace_worst_point(in_contracted)
                    return nil
                end

            end

            x_smallest = @simplex[0].point
            0.upto(@simplex.length-1) do |i|
                x = @simplex[i].get_point()
                0.upto(n-1) do |j|
                    x[j] = x_smallest[j] + @sigma * (x[j] - x_smallest[j])
                end
                @simplex[i] = RealPointValuePair.new(x, Float::NAN)
            end
            puts "----------------------------"
            evaluate_simplex()
        end
    end

end

x = NelderMead.new
val = x.optimize([0, 0])
puts "results :  #{val.get_point}     #{val.value}"
