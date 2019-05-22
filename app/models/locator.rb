# frozen_string_literal: true

# @api krill
class Locator < ActiveRecord::Base

  attr_accessible :item_id, :number, :wizard_id

  belongs_to :wizard
  has_one :item, autosave: false

  # validate :no_collisions
  validate :has_wizard
  validates :number, uniqueness: { scope: :wizard_id, message: "Should have max one locator per location" }

  def has_wizard
    errors.add(:no_wizard, 'no wizard') unless
      wizard_id && wizard_id >= 0
  end

  def no_collisions
    puts "Checking for collisions for #{id}"
    c = Locator.where(wizard_id: wizard_id, number: number)
    if c.length == 1 && c.first != self
      errors.add(:locator_collision, "Locator #{c.first.id} already has number #{number}.")
    elsif c.length > 1
      errors.add(:locator_collision, "Multiple Locators have number #{number}.")
    end
  end

  def to_s
    if wizard
      wizard.int_to_location number
    else
      'ERROR'
    end
  end

  def self.first_empty(wizard)
    return unless wizard

    locs = where(wizard_id: wizard.id, item_id: nil)
    if !locs.empty?
      locs.first
    else
      m = Locator.largest wizard
      loc = Locator.new(wizard_id: wizard.id, number: m ? m.number + 1 : 0)
      loc.save
      loc
    end
  end

  def empty?
    item_id.nil?
  end

  def self.largest(wizard)
    # find greatest locator for this wizard, should always be the most recent
    wizard.locators.order("id desc").first
  end

  def self.port(wizard)

    # e.g. Locator.port Wizard.find_by_name("M20")

    ots = ObjectType.where(prefix: wizard.name)
    items = ots.collect(&:items).flatten.select { |i| wizard.has_correct_form i.primitive_location }
    maxitem = items.max_by { |i| puts i.id; wizard.location_to_int(i.primitive_location) }
    max = wizard.location_to_int maxitem.primitive_location

    collisions = []

    # insert block of new locators
    (0..max).each do |n|
      Locator.new(
        number: n,
        wizard_id: wizard.id
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

  def self.port_all

    port Wizard.find_by_name('M20')
    port Wizard.find_by_name('M80')
    port Wizard.find_by_name('SF2')
    port Wizard.find_by_name('DFP')

  end

  def clear
    r1 = false
    r2 = false
    transaction do
      item.locator_id = nil
      r1 = item.save
      self.item_id = nil
      r2 = save
    end
    r1 && r2
  end

end
