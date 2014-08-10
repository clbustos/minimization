module Minimization
  # class which holds the point,value pair
  class PointValuePair
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
end
