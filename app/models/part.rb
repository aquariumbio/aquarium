class Part

  attr_accessor :collection, :x, :y

  def initialize(c, x, y)
    @collection = c
    @x = x
    @y = y
    raise 'out of range' unless x < c.dimensions[0] && y < c.dimensions[1]
  end

  def sample
    Sample.find_by(id: @collection.matrix[@x][@y])
  end

  def sample_type
    @collection.matrix[@x][@y].sample_type
  end

  def object_type
    @collection.object_type
  end

end
