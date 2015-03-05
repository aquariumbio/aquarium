class Wizard < ActiveRecord::Base

  attr_accessible :name, :specification, :description

  validates :name, presence: true
  validates :description, presence: true
  validates_uniqueness_of :name

  has_many :locators

  def spec # converts the specification into a reasonable ruby object

    if !self.specification || self.specification == "null"

      {}

    elsif self.specification

      s = JSON.parse(self.specification,symbolize_names:true)
      t = []

      s[:fields].each do |k,v|
        vnew = { name: v[:name], capacity: v[:capacity].to_i }
        t[k.to_s.to_i] = vnew
      end

      s[:fields] = t
      s

    end

  end

  def limit # returns the number of elements in the main component of the location
    self.spec[:fields].last[:capacity]
  end

  def object_types
    ObjectType.where(prefix: self.name)
  end

  def items
    Item.joins(:object_type).where(object_types: { prefix: self.name })
  end

  def caps
    if self.spec[:fields]
      self.spec[:fields].collect { |f| f[:capacity] }
    else
      {}
    end
  end

  def parts loc
    loc.split('.').collect { |v| v.to_i }
  end

  def location_to_int loc

    raise "Could not convert location string '#{loc}' to int." unless loc.class == String

    c = caps
    mx,my,mz = c
    w,x,y,z = parts loc

    if c.length == 3
      return z + mz*y + my*mz*x
    elsif c.length == 2
      return y + my*x
    elsif c.length == 1
      return x
    else
      return 0
    end

  end

  def int_to_location n

    c = caps
    mx,my,mz = c

    if c.length == 3
      x = n / ( my*mz )
      q = n % ( my*mz )
      y = q / mz
      z = q % mz
      return "#{self.name}.#{x}.#{y}.#{z}"
    elsif c.length == 2
      x = n / my
      y = n % my
      return "#{self.name}.#{x}.#{y}"
    elsif c.length == 1
      return "#{self.name}.#{n}"
    else
      return "#{self.name}"
    end

  end

  def has_correct_form loc
    return false unless loc.class == String
    c = caps   
    parts = loc.split('.')
    return false unless parts[0] == name 
    return false unless parts.length - 1 == c.length
    (1..c.length).each do |i|
      if i == 1
        return false unless parts[i].to_i >= 0 
      else 
        return false unless parts[i].to_i < c[i-1]
      end
    end
    return true
  end

  def next 
    n = Locator.first_empty self
    if !n
      max = (Locator.largest self).number
      n = Locator.new wizard_id: id, number: max+1
    end
    n
  end

  def addnew locstr # add all locations up to and including 
                    # locstr, and return the last one

    m = Locator.largest self

    if m

      num = self.location_to_int locstr
      loc = nil

      # insert block of new locators
      (m.number+1..num).each do |n|
         loc = Locator.new(
           number: n, 
           wizard_id: self.id, 
         )
         loc.save
      end

    else 

      loc = Locator.new number: 0, wizard_id: self.id
      loc.save

    end

    loc

  end

  def largest
    Locator.largest self
  end

  def boxes # for wizards of the form name.a.b.c, returns all locations of the form name.a.b

    l = largest

    if l 
      loc = l.to_s
    else
      return []
    end

    w,x,y,z = parts loc
    mx,my,mz = caps

    b = (0..x).collect do |a|
      (0..(a==x ? y : my)).collect do |b|
        "#{name}.#{a}.#{b}"
      end
    end

    b.flatten

  end

  def box b
    loc = b + '.0'
    min = location_to_int loc
    max = min + caps[2] - 1
    puts "#{min},#{max}"
    Locator.includes(item: [:object_type, :sample]).where("wizard_id = ? AND ? <= number AND number <= ?", id, min, max)
  end

  def self.wizard_for locstr
    find_by_name(locstr.split('.').first)
  end

  def self.find_locator locstr
    wiz = wizard_for locstr
    n = wiz.location_to_int locstr
    Locator.where(wizard_id: wiz.id, number: n).first
  end

end


