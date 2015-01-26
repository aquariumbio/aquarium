class Wizard < ActiveRecord::Base

  attr_accessible :name, :specification, :description

  validates :name, presence: true
  validates :description, presence: true
  validates_uniqueness_of :name

  def spec # converts the specification into a reasonable ruby object

    if self.specification

      s = JSON.parse(self.specification,symbolize_names:true)
      t = []

      s[:fields].each do |k,v|
        vnew = { name: v[:name], min: v[:min].to_i, max: v[:max].to_i}
        t[k.to_s.to_i] = vnew
      end

      s[:fields] = t
      s

    else

      {}

    end

  end

  def object_types
    ObjectType.where(prefix: self.name)
  end

  def items
    Item.joins(:object_type).where(object_types: { prefix: self.name })
  end

  def locations
    Item.joins(:object_type)
      .where(object_types: { prefix: self.name })
      .select("location")
      .collect { |i| i.location }
  end

  def maxes
    self.spec[:fields].collect { |f| f[:max] }
  end

  def next loc
    max = self.maxes
    parts = loc.split('.')
    num_fields = parts.length
    # increase least significant field
    # if it is greater than max, set it to zero and increase the next field
    # if there is no next field, then return nil
  end

  def min_empty_location
    ""
  end

end
