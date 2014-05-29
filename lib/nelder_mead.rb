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
    def initialize(point, value)
        @point = point.clone
        @value  = value
    end

    #def initialize(point,value,copyArray)
    #    this.point = copyArray ? point.clone() : point;
    #    this.value  = value;
    #end

    def getPoint()
        return @point.clone
    end

    def getPointRef()
        return @point
    end

    def getValue()
        return @value
    end
end

class DirectSearchOptimizer

    def converged(a,b,c)
@tmp += 1
        if(@tmp < 100)
            false
        else
            true
        end
        # change this
    end

    def f(x)
            return (x[0]-2)**2
        # change this
    end

    def initialize(iterateSimplexRef)
@tmp = 0
        @maxIterations  = 100000
        @maxEvaluations = 100000
        @iterateSimplexRef = iterateSimplexRef
    end

    def iterateSimplex()
        return iterateSimplexRef.call
    end

    def setStartConfiguration(steps)
        n = steps.length
        @startConfiguration = Array.new(n) { Array.new(n) }
        0.upto(n-1) do |i|
            vertexI = @startConfiguration[i]
            0.upto(i) do |j|
                if (steps[j] == 0.0)
                    raise "error"
                end
                0.upto(j+1) do |k|
                    vertexI[k] = steps[k]
                end
            end
        end
    end

   # def setStartConfiguration(referenceSimplex)
   #      "bbbbbbbbbbbbbbbbbbbbbbb"
   #     n = referenceSimplex.length - 1
   #     if (n < 0)
   #        puts "simplex must contain at least one point"
   #        return
   #     end
   #     @startConfiguration = Array.new(n) { Array.new(n) }
   #     ref0 = referenceSimplex[0]

   #     0.upto(n) do |i|
   #         refI = referenceSimplex[i]
   #         if (refI.length != n)
   #             puts "dimension mismatch #{refI.length} != #{n}"
   #             return
   #         end
   #         0.upto(i-1) do |j|
   #             refJ = referenceSimplex[j]
   #             allEquals = true
   #             0.upto(n-1) do |k|
   #                 if (refI[k] != refJ[k])
   #                     allEquals = false
   #                     break
   #                 end
   #             end
   #             if (allEquals)
   #                 puts "equals vertices #{i} and #{j} in simplex configuration"
   #                 return
   #             end
   #         end

   #         if (i > 0)
   #             confI = @startConfiguration[i - 1]
   #             0.upto(n-1) do |k|
   #                 confI[k] = refI[k] - ref0[k]
   #             end
   #         end
   #     end
   # end

    def compare(v1, v2)
        if v1.getValue == v2.getValue
            return 0
        elsif v1.getValue > v2.getValue
            return -1
        else
            return 1
        end
    end

    def optimize(startPoint)
        if @startConfiguration == nil
            unit = Array.new(startPoint.length) { 1.0 }
            setStartConfiguration(unit)
        end

        @iterations  = 0
        @evaluations = 0
        buildSimplex(startPoint)
        evaluateSimplex()

        @previous = Array.new(@simplex.length)
        loop do
            if @iterations > 0
                converged = true
                0.upto(@simplex.length-1) do |i|
                    converged &= converged(@iterations, @previous[i], @simplex[i])
                end
                if (converged)
                    return @simplex[0]
                end
            end

            @previous = @simplex[0..(@previous.length-1)]      # check again for requirement
            #System.arraycopy(@simplex, 0, previous, 0, @simplex.length)
            iterateSimplex()
        end
        #for i in 0..(@simplex.length-1)
        #    puts "#{@simplex[i].getValue}     #{@simplex[i].getPointRef}"
        #end
    end

    def incrementIterationsCounter()
        @iterations += 1
        #raise "iteration limit reached" if @iterations > @maxIterations
    end

    def evaluate(x)
         @evaluations += 1
        #raise "evaluation error!" if (@evaluations > @maxEvaluations)
        return f(x)
    end

    def buildSimplex(startPoint)
        n = startPoint.length
        raise "dimension mismatch" if n != @startConfiguration.length

        @simplex = Array.new(n+1)
        @simplex[0] = RealPointValuePair.new(startPoint, Float::NAN)

        0.upto(n-1) do |i|
            confI   = @startConfiguration[i]
            vertexI = Array.new(n)
            0.upto(n-1) do |k|
                vertexI[k] = startPoint[k] + confI[k]
            end
            @simplex[i + 1] = RealPointValuePair.new(vertexI, Float::NAN)
        end

    end

     def evaluateSimplex()
        0.upto(@simplex.length-1) do |i|
            vertex = @simplex[i]
            point = vertex.getPointRef()
            if vertex.getValue().nan?
                @simplex[i] = RealPointValuePair.new(point, evaluate(point))
            end
puts "evaluate simplex : #{@simplex[i].getValue}     #{@simplex[i].getPointRef}"
        end
        @simplex.sort!{ |x1, x2| x1.getValue <=> x2.getValue }
        puts "sorted"
        0.upto(@simplex.length-1) do |i|
            puts "#{@simplex[i].getPointRef}   #{@simplex[i].getValue}"
        end
    end

    def replaceWorstPoint(pointValuePair)
        n = @simplex.length - 1
        0.upto(n-1) do |i|
            if (compare(@simplex[i], pointValuePair) > 0)
                tmp            = @simplex[i]
                @simplex[i]     = pointValuePair
                pointValuePair = tmp
            end
        end
        @simplex[n] = pointValuePair
    end
end

class NelderMead < DirectSearchOptimizer

    def initialize()
        super(proc{iterateSimplex})
        @rho   = 1.0;
        @khi   = 2.0;
        @gamma = 0.5;
        @sigma = 0.5;
    end

    #public NelderMead(final double rho, final double khi,
    #                  final double gamma, final double sigma) {
    #    this.rho   = rho;
    #    this.khi   = khi;
    #    this.gamma = gamma;
    #    this.sigma = sigma;
    #}

    def iterateSimplex()
        incrementIterationsCounter()
        n = @simplex.length - 1
        best       = @simplex[0]
        secondBest = @simplex[n-1]
        worst      = @simplex[n]
        xWorst     = worst.getPointRef()

        centroid = Array.new(n, 0)

        0.upto(n-1) do |i|
            x = @simplex[i].getPointRef()
            0.upto(n-1) do |j|
                centroid[j] += x[j]
            end
        end
        scaling = 1.0 / n
        0.upto(n-1) do |j|
            centroid[j] *= scaling
        end

        xR = Array.new(n)
        0.upto(n-1) do |j|
            xR[j] = centroid[j] + @rho * (centroid[j] - xWorst[j])
        end
        reflected = RealPointValuePair.new(xR, evaluate(xR))

        if ((compare(best, reflected) <= 0) && (compare(reflected, secondBest) < 0))
            replaceWorstPoint(reflected)

        elsif (compare(reflected, best) < 0)
            xE = Array.new(n)
            0.upto(n-1) do |j|
                xE[j] = centroid[j] + @khi * (xR[j] - centroid[j])
            end
            expanded = RealPointValuePair.new(xE, evaluate(xE))

            if (compare(expanded, reflected) < 0)
                replaceWorstPoint(expanded)
            else
                replaceWorstPoint(reflected)
            end

        else
            if (compare(reflected, worst) < 0)
                xC = Array.new(n)
                0.upto(n-1) do |j|
                    xC[j] = centroid[j] + @gamma * (xR[j] - centroid[j])
                end
                outContracted = RealPointValuePair.new(xC, evaluate(xC))

                if (compare(outContracted, reflected) <= 0)
                    replaceWorstPoint(outContracted)
                    return
                end

            else
                xC = Array.new(n)
                0.upto(n-1) do |j|
                    xC[j] = centroid[j] - @gamma * (centroid[j] - xWorst[j])
                end
                inContracted = RealPointValuePair.new(xC, evaluate(xC))

                if (compare(inContracted, worst) < 0)
                    replaceWorstPoint(inContracted)
                    return
                end

            end

            xSmallest = @simplex[0].getPointRef()
            0.upto(@simplex.length-1) do |i|
                x = @simplex[i].getPoint()
                0.upto(n-1) do |j|
                    x[j] = xSmallest[j] + @sigma * (x[j] - xSmallest[j])
                end
                @simplex[i] = RealPointValuePair.new(x, Float::NAN)
            end
            puts "bbbbbbbbbbbbbbbbbbbbbbbbbbBBB"
            evaluateSimplex()
        end
    end

end

x = NelderMead.new
val = x.optimize([0, 0])
puts "results :  #{val.getPoint}     #{val.getValue}"
