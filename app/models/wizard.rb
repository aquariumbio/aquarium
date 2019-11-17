# frozen_string_literal: true

class Wizard < ActiveRecord::Base

  attr_accessible :name, :specification, :description

  validates :name, presence: true
  validates :description, presence: true
  validates :name, uniqueness: true

  has_many :locators

  def self.conflicts

    wizards = Wizard.all.collect do |wizard|
      numbers = Locator.where(wizard_id: wizard.id).pluck(:number)
      {
        wizard: wizard,
        conflicts: numbers.group_by { |e| e }
                          .select { |k, v| v.size > 1 }
                          .map(&:first)
                          .map { |i| wizard.int_to_location i }
      }
    end
    wizards.reject { |x| x[:conflicts].empty? }

  end

  def conflicts
    nums = Locator.where(wizard_id: id).pluck(:number)
    nums.group_by { |e| e }
        .select { |k, v| v.size > 1 }
        .map(&:first)
        .map { |i| int_to_location i }
  end

  def spec # converts the specification into a reasonable ruby object
    return {} if !specification || specification == 'null'

    s = JSON.parse(specification, symbolize_names: true)
    t = []

    s[:fields].each do |k, v|
      vnew = { name: v[:name], capacity: v[:capacity].to_i }
      t[k.to_s.to_i] = vnew
    end
    s[:fields] = t

    s
  end

  def limit # returns the number of elements in the main component of the location
    spec[:fields].last[:capacity]
  end

  def object_types
    ObjectType.where(prefix: name)
  end

  def items
    Item.joins(:object_type).where(object_types: { prefix: name })
  end

  def caps
    return {} unless spec[:fields]

    spec[:fields].collect { |f| f[:capacity] }
  end

  def parts(loc)
    loc.split('.').collect(&:to_i)
  end

  def location_to_int(loc)
    raise "Could not convert location string '#{loc}' to int." unless loc.class == String

    c = caps
    _mx, my, mz = c
    _w, x, y, z = parts loc
    return z + mz * y + my * mz * x if c.length == 3
    return y + my * x if c.length == 2
    return x if c.length == 1

    0
  end

  def int_to_location(n)
    c = caps
    _mx, my, mz = c

    if c.length == 3
      x = n / (my * mz)
      q = n % (my * mz)
      y = q / mz
      z = q % mz
      return "#{name}.#{x}.#{y}.#{z}"
    end

    if c.length == 2
      x = n / my
      y = n % my
      return "#{name}.#{x}.#{y}"
    end

    return "#{name}.#{n}" if c.length == 1

    name.to_s
  end

  def has_correct_form(loc)
    return false unless loc.class == String

    c = caps
    parts = loc.split('.')
    return false unless parts[0] == name
    return false unless parts.length - 1 == c.length

    (1..c.length).each do |i|
      if i == 1
        return false unless parts[i].to_i >= 0
      else
        return false unless parts[i].to_i < c[i - 1]
      end
    end
    true
  end

  def next
    n = Locator.first_empty self
    unless n
      max = (Locator.largest self).number
      n = Locator.new wizard_id: id, number: max + 1
    end
    n
  end

  def addnew(locstr) # add all locations up to and including
    # locstr, and return the last one

    m = Locator.largest self

    if m

      num = location_to_int locstr
      loc = nil

      # insert block of new locators
      (m.number + 1..num).each do |n|
        loc = Locator.new(
          number: n,
          wizard_id: id
        )
        loc.save
      end

    else

      loc = Locator.new number: 0, wizard_id: id
      loc.save

    end

    loc

  end

  def largest
    Locator.largest self
  end

  def boxes # for wizards of the form name.a.b.c, returns all locations of the form name.a.b
    return [] unless largest

    loc = largest.to_s
    _w, x, y, _z = parts loc
    _mx, my, _mz = caps

    box_list = (0..x).collect do |a|
      (0..(a == x ? y : my)).collect do |b|
        "#{name}.#{a}.#{b}"
      end
    end

    box_list.flatten
  end

  def box(b)
    loc = b + '.0'
    min = location_to_int loc
    max = min + caps[2] - 1
    puts "#{min},#{max}"
    Locator.includes(item: %i[object_type sample]).where('wizard_id = ? AND ? <= number AND number <= ?', id, min, max)
  end

  def self.wizard_for(locstr)
    find_by(name: locstr.split('.').first)
  end

  def self.find_locator(locstr)
    wiz = wizard_for locstr
    n = wiz.location_to_int locstr
    Locator.find_by(wizard_id: wiz.id, number: n)
  end

end
