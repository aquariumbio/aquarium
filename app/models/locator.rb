class Locator < ActiveRecord::Base

  attr_accessible :item_id, :number, :wizard_id

  belongs_to :wizard
  has_one :item, autosave: false

  # validate :no_collisions

  def no_collisions
    puts "Checking for collisions for #{self.id}"
    c = Locator.where(wizard_id: wizard_id,number: number)
    if c.length == 1 && c.first != self
      errors.add(:locator_collision,"Locator #{c.first.id} already has number #{number}.")
    elsif c.length > 1
      errors.add(:locator_collision,"Multiple Locators have number #{number}.")
    end
  end

  def to_s
    wizard.int_to_location number
  end

  def self.first_empty wizard
    if wizard
      locs = where(wizard_id: wizard.id, item_id: nil)
      if locs.length > 0
        locs.first
      else 
        loc = Locator.new(wizard_id: wizard.id, number: 0)
        loc.save
        loc
      end
    else
      nil
    end
  end

  def empty?
    item_id == nil
  end

  def self.largest wizard
    # find greatest locator for this wizard, should always be the most recent
    wizard.locators.last(order: "id desc", limit: 1)
  end

  def self.port wizard

    # e.g. Locator.port Wizard.find_by_name("M20")

    ots = ObjectType.where(prefix: wizard.name)
    items = (ots.collect { |ot| ot.items }).flatten.select { |i| wizard.has_correct_form i.primitive_location }
    maxitem = items.max_by { |i| puts i.id; wizard.location_to_int(i.primitive_location) }
    max = wizard.location_to_int maxitem.primitive_location

    collisions = []

    # insert block of new locators
    (0..max).each do |n|
       Locator.new(
         number: n, 
         wizard_id: wizard.id, 
       ).save
    end

    # insert locators
    items.each do |i| 

      n = wizard.location_to_int(i.primitive_location)
      l = Locator.where(wizard_id: wizard.id, number: n).first

      if l.item_id
        collisions.push([l.item_id, i.id])
      else
        l.item_id = i.id
        l.save
        i.locator_id = l.id
        i.save
      end

    end

    collisions

  end

  def clear
    r1,r2 = [false,false]
    transaction do
      item.locator_id = nil      
      r1 = item.save 
      self.item_id = nil
      r2 = self.save 
    end
    r1 && r2
  end

end


