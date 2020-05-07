# typed: false
# frozen_string_literal: true

require 'sorbet-runtime'

# Class that represents a physical object in the lab
# Has an {ObjectType} that declares what kind of physical thing it is, and may have a {Sample} defining the specimen that resides within.
# @api krill
class Item < ActiveRecord::Base
  extend T::Sig

  include DataAssociator

  # associations #######################################################

  belongs_to :object_type
  belongs_to :sample
  has_one :part
  has_one :locator, autosave: false
  has_many :post_associations

  # accessors ###########################################################

  attr_accessible :quantity, :inuse, :sample_id, :data, :object_type_id,
                  :created_at, :collection_id, :locator_id,
                  :sample_attributes, :object_type_attributes, :location

  # Gets the sample inside this Item.
  #
  # @return [Sample] kind of specimen contained in this Item, if any.
  #             Some Items correspond to Samples and some do not.
  #             For example, an Item whose object type is "1 L Bottle"
  #             does not correspond to a sample. An item whose ObjectType is "Plasmid Stock"
  #             will have a corresponding Sample, whose name might be something like "pLAB1".
  accepts_nested_attributes_for :sample

  # Gets the ObjectType of Item.
  #
  # @return [ObjectType]  type of object that this Item represents a
  #               unique physical instantiation of
  accepts_nested_attributes_for :object_type

  # validations #########################################################

  validates :quantity, presence: true
  validate :quantity_nonneg

  validates :inuse, presence: true
  validate :inuse_less_than_quantity

  def quantity_nonneg
    errors.add(:quantity, 'Must be non-negative.') unless
      quantity && quantity >= -1
  end

  def inuse_less_than_quantity
    errors.add(:inuse, 'must non-negative and not greater than the quantity.') unless
      quantity && inuse && inuse >= -1 && inuse <= quantity
  end

  # location methods ###############################################################

  sig { returns(String) }
  def primitive_location
    self[:location]
  end

  # @private
  sig { returns(ObjectType) }
  def part_type
    @@part_type ||= ObjectType.part_type
  end

  # Returns true if the item is a part of a collection
  # @return [Bool]
  sig { returns(T::Boolean) }
  def is_part
    object_type_id == part_type.id
  end

  # Returns the location of the Item
  #
  # @return [String] the description of the Item's physical location in the lab as a string
  sig { returns(String) }
  def location
    if is_part
      'Part of Collection'
    elsif locator
      locator.to_s
    elsif primitive_location
      primitive_location
    else
      'Unknown'
    end
  end

  # Sets the location of the Item.
  #
  # @param x [String] the location string
  def location=(x)
    move_to x
    self[:location] = x # just for consistency
  end

  def set_primitive_location(locstr)
    self[:location] = locstr
  end

  # Sets item location to empty slot based on location {Wizard}. By default sets to "Bench".
  #
  # @return [Item] self
  def store
    wiz = Wizard.find_by(name: object_type.prefix)
    if wiz
      locator = wiz.next
      move_to(wiz.int_to_location(locator.number))
    else
      move_to 'Bench'
    end
  end

  # Sets item location to provided string or to string's associated location {Wizard} if it exists.
  #
  # @param locstr [String] the location string
  # @return [Item] self
  sig { params(location_name: String).returns(Item) }
  def move_to(location_name)

    wiz = Wizard.find_by(name: object_type.prefix) if object_type

    if object_type && wiz && wiz.has_correct_form(location_name) # item and location managed by a wizard

      unless wiz.has_correct_form location_name
        errors.add(:wrong_form, "'#{location_name}'' is not in the form of a location for the #{wiz.name} wizard.")
        return
      end

      locs = Locator.where(wizard_id: wiz.id, number: (wiz.location_to_int location_name))

      case locs.length
      when 0
        newloc = wiz.addnew location_name
      when 1
        newloc = locs.first
      else
        errors.add(:too_many_locators, "There are multiple items at #{location_name}.")
        return
      end

      if newloc == locator
        errors.add(:already_there, "Item is already at #{location_name}.")
        return nil
      end

      if newloc.item_id.nil?

        oldloc = Locator.find_by(id: locator_id)
        oldloc.item_id = nil if oldloc
        self.locator_id = newloc.id
        self[:location] = location_name
        self.quantity = 1
        self.inuse = 0
        newloc.item_id = id

        transaction do
          save
          oldloc.save if oldloc
          newloc.save
        end

        reload
        oldloc.reload if oldloc
        puts "newloc = #{newloc.inspect}"
        newloc.reload

        errors.add(:locator_save_error, "Error: '#{errors.full_messages.join(',')}'") unless errors.empty?

      else

        errors.add(:locator_taken, "Location taken by item #{newloc.item_id}.")

      end

    else # location is not in the form managed by a wizard

      loc = Locator.find_by(id: locator_id)
      loc.item_id = nil if loc

      self[:location] = location_name
      self.locator_id = nil

      transaction do
        save
        loc.save if loc
      end

      raise errors.full_messages.join(',') unless errors.empty?

      reload

    end

    self

  end

  sig { returns(T::Boolean) }
  def non_wizard_location?
    wiz = Wizard.find_by(name: object_type.prefix)

    !(wiz && locator.nil?)
  end

  # (see #move_to)
  #
  # @note for backwards compatibility
  def move(locstr)
    move_to locstr
  end

  def self.make(params, opts = {})
    o = { object_type: nil, sample: nil, location: nil }.merge opts

    if o[:object_type]
      loc = params['location']
      params.delete 'location'
      item = new params.merge(object_type_id: o[:object_type].id)
      item.save
      item.location = loc if loc
    else
      item = new params
    end

    item.sample_id = o[:sample].id if o[:sample]

    if o[:object_type]
      item.object_type_id = o[:object_type].id
      wiz = Wizard.find_by(name: o[:object_type].prefix)
      locator = wiz.next if wiz
      item.set_primitive_location locator.to_s if wiz
    end

    if locator
      ActiveRecord::Base.transaction do
        item.save
        locator.item_id = item.id
        locator.save
        item.locator_id = locator.id
        item.save
        locator.save
      end
    else
      item.save
    end

    item.reload
    logger.info "Made new item #{item.id} with location #{item.location} and primitive location #{item.primitive_location}"

    item
  end

  def put_at(locstr)
    loc = Wizard.find_locator locstr
    return nil unless loc && loc.item_id.nil?

    loc.item_id = id
    transaction do
      loc.save
      save
    end
  end

  # Delete the Item (sets item's location to "deleted").
  #
  # @return [Bool] true if the location is set to 'deleted', false otherwise
  sig { returns(T::Boolean) }
  def mark_as_deleted
    self[:location] = 'deleted'
    self.quantity = -1
    self.inuse = -1
    self.locator_id = nil
    locator.item_id = nil if locator

    item_saved = false
    locator_saved = false

    transaction do
      item_saved = save
      locator_saved = locator.save if locator
    end

    item_saved && locator_saved
  end

  # Indicates whether this Item is deleted.
  #
  # @return [Bool] true if this Item is deleted, false otherwise
  def deleted?
    primitive_location == 'deleted'
  end

  # Indicates whether this Item is a Collection.
  #
  # @return [Bool] true if this Item is a Collection, false otherwise
  def collection?
    object_type && object_type.handler == 'collection'
  end

  # Returns the parent Collection of this item, if it is a part. Otherwise, returns nil
  # @return [Collection]
  def containing_collection
    pas = PartAssociation.where(part_id: id)
    pas[0].collection if pas.length == 1
  end

  # other methods ############################################################################

  def set_data(d)
    self.data = d.to_json
    save
  end

  def get_data
    JSON.parse data, symbolize_names: true
  rescue JSON::ParserError
    nil
  end

  # @deprecated Use {DataAssociator} methods instead of datum
  def datum
    JSON.parse(data, symbolize_names: true)
  rescue StandardError
    {}
  end

  # (see #datum)
  def datum=(d)
    self.data = d.to_json
  end

  def annotate(hash)
    set_data(datum.merge(hash))
  end

  def features
    f = { id: id, location: location, name: object_type.name }
    f = f.merge(sample: sample.name, type: sample.sample_type.name) if sample_id
    f
  end

  def all_attributes
    temp = attributes.symbolize_keys
    temp[:object_type] = object_type.attributes.symbolize_keys
    temp[:sample] = sample.attributes.symbolize_keys if sample_id

    temp
  end

  def to_s
    "<a href='#' onclick='open_item_ui(#{id})'>#{id}</a>"
  end

  def upgrade(force = false) # upgrades data field to data association (if no data associations exist)
    if force || associations.empty?
      begin
        obj = JSON.parse data

        obj.each do |k, v|
          associate k, v
        end
      rescue StandardError
        self.notes = data if data
      end
    else
      append_notes "\n#{Date.today}: Attempt to upgrade failed. Item already had associations."
    end
  end

  # scopes for searching Items
  def self.with_sample(sample:)
    includes(:locator).includes(:object_type).where(sample_id: sample.id)
  end

  ###########################################################################
  # OLD
  ###########################################################################

  def self.new_object(name)
    olist = ObjectType.where('name = ?', name)
    raise "Could not find object type named '#{spec[:object_type]}'." if olist.empty?

    Item.make({ quantity: 1, inuse: 0 }, object_type: olist[0])

  end

  def self.new_sample(name, spec)

    raise 'No Sample Type Specified (with :of)' unless spec[:of]
    raise 'No Container Specified (with :in)' unless spec[:as]

    olist = ObjectType.where('name = ?', spec[:as])
    raise "Could not find container named '#{spec[:as]}'." if olist.empty?

    sample_type_id = SampleType.find_by(name: spec[:of])
    raise "Could not find sample type named '#{spec[:of]}'." unless sample_type_id

    slist = Sample.where('name = ? AND sample_type_id = ?', name, sample_type_id)
    raise "Could not find sample named #{name}" if slist.empty?

    Item.make({ quantity: 1, inuse: 0 }, sample: slist[0], object_type: olist[0])

  end

  def num_posts
    post_associations.count
  end

  def export
    a = attributes
    a.delete 'inuse'
    a.delete 'locator_id'
    data = get_data
    a['data'] = data if data
    a[:sample] = sample.export if association(:sample).loaded?
    a[:object_type] = object_type.export if association(:object_type).loaded?
    a
  end

  def week
    created_at.strftime('%W')
  end

  def self.items_for(sid, oid)
    sample = Sample.find_by(id: sid)
    ot = ObjectType.find_by(id: oid)

    if sample
      return [] unless ot
      return Collection.parts(sample, ot) if ot.handler == 'collection'

      return sample.items.reject { |i| i.deleted? || i.object_type_id != ot.id }
    end
    return ot.items.reject(&:deleted?) if ot.handler != 'sample_container'

    []
  end

end
