class Item < ActiveRecord::Base

  # associations #######################################################

  belongs_to :object_type
  belongs_to :sample
  has_many :touches
  has_one :part
  has_many :cart_items
  has_many :takes
  has_one :locator, autosave: false

  # accessors ###########################################################

  attr_accessible :quantity, :inuse, :sample_id, :data, :object_type_id,
                  :created_at, :collection_id, :locator_id, :location,
                  :sample_attributes, :object_type_attributes

  accepts_nested_attributes_for :sample, :object_type

  # validations #########################################################

  validates :quantity, :presence => true
  validate :quantity_nonneg

  validates :inuse,    :presence => true
  validate :inuse_less_than_quantity

  def quantity_nonneg
    errors.add(:quantity, "Must be non-negative." ) unless
      self.quantity && self.quantity >= -1 
  end

  def inuse_less_than_quantity
    errors.add(:inuse, "must non-negative and not greater than the quantity." ) unless
      self.quantity && self.inuse && self.inuse >= -1 && self.inuse <= self.quantity
  end

  # location methods ###############################################################

  def primitive_location
    self[:location]
  end

  def location
    if locator
      locator.to_s
    else
      primitive_location
    end
  end

  def location= x
    move_to x
    write_attribute(:location,x) # just for consistency
  end

  def move_to locstr 

    wiz = Wizard.find_by_name(object_type.prefix)

    if object_type && wiz && wiz.has_correct_form( locstr ) # item and location managed by a wizard

      unless wiz.has_correct_form locstr
        errors.add(:wrong_form, "'#{locstr}'' is not in the form of a location for the #{wiz.name} wizard." )
        return
      end

      locs = Locator.where(wizard_id: wiz.id, number: (wiz.location_to_int locstr))

      case locs.length 
        when 0
          newloc = wiz.addnew locstr
        when 1
          newloc = locs.first 
          puts "using exsting location #{newloc.id}"
        else         
          errors.add(:too_many_locators, "There are multiple items at #{locstr}." )
          return
      end

      if newloc == locator
        errors.add(:already_there, "Item is already at #{locstr}." )
        return nil
      end

      if newloc.item_id == nil

        oldloc = Locator.find_by_id(locator_id)
        oldloc.item_id = nil if oldloc
        self.locator_id = newloc.id
        write_attribute(:location,locstr)
        self.quantity = 1
        self.inuse = 0
        newloc.item_id = id

        transaction do 
          self.save
          oldloc.save if oldloc
          newloc.save
        end

        reload
        oldloc.reload if oldloc
        newloc.reload

        errors.add(:locator_save_error, "Error: '#{errors.full_messages.join(',')}'") unless errors.empty? 

      else

        errors.add(:locator_taken, "Location taken by item #{newloc.item_id}.")

      end

    else # location is not in the form managed by a wizard

      loc = Locator.find_by_id(locator_id)
      loc.item_id = nil if loc
      self.locator_id = nil
      write_attribute(:location,locstr)

      puts loc
      puts self

      transaction do
        self.save
        loc.save if loc
      end


    end

    self

  end

  def move locstr # for backwards compatability
    move_to locstr
  end

  def self.make params, opts={}

    # Make a new item with the specified object type and sample information.
    # This method creates a new locator if the object_type is associated with a
    # location wizard.

    o = { object_type: nil, sample: nil, location: nil }.merge opts

    item = self.new params

    if o[:sample]
      item.sample_id = o[:sample].id
    end

    if o[:object_type]
      item.object_type_id = o[:object_type].id
      wiz = Wizard.find_by_name(o[:object_type].prefix)
      locator = wiz.next if wiz
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

    item

  end

  def put_at locstr

    loc = Wizard.find_locator locstr
    return nil unless loc && loc.item_id == nil
    loc.item_id = id
    item_id = loc.id
    transaction do
      loc.save
      save
    end

  end
 
  def mark_as_deleted 

    write_attribute(:location,'deleted')
    self.quantity = -1
    self.inuse = -1
    self.locator_id = nil
    locator.item_id = nil if locator

    r1,r2 = [false,false]

    transaction do
      r1 = self.save
      r2 = locator.save if locator
    end

    r1 && r2

  end

  def deleted?
    primitive_location == 'deleted'
  end

  # other methods ############################################################################

  def set_data d
    self.data = d.to_json
    self.save
  end

  def get_data
    JSON.parse self.data, symbolize_names: true
  end

  def datum
    begin
      JSON.parse self.data, symbolize_names: true
    rescue
      {}
    end
  end

  def datum= d
    self.data = d.to_json
  end

  def features
    f = { id: self.id, location: self.location, name: self.object_type.name }
    if self.sample_id
      f = f.merge({ sample: self.sample.name, type: self.sample.sample_type.name })
    end
    f
  end

  def all_attributes

    temp = self.attributes.symbolize_keys

    temp[:object_type] = self.object_type.attributes.symbolize_keys

    if self.sample_id
      temp[:sample] = self. sample.attributes.symbolize_keys
    end

    return temp

  end

  def to_s
    "<a href='/items/#{self.id}' class='aquarium-item' id='#{self.id}'>#{self.id}</a>"
  end

  ###########################################################################
  # OLD 
  ###########################################################################

  def self.new_object name

    i = self.new
    olist = ObjectType.where("name = ?", name)
    raise "Could not find object type named '#{spec[:object_type]}'." unless olist.length > 0
    i.object_type_id = olist[0].id
    i.location = olist[0].location_wizard
    i.quantity = 1
    i.inuse = 0
    i.save
    i

  end

  def self.new_sample name, spec

    raise "No Sample Type Specified (with :of)" unless spec[:of]
    raise "No Container Specified (with :in)" unless spec[:as]

    i = self.new

    olist = ObjectType.where("name = ?", spec[:as])
    raise "Could not find container named '#{spec[:as]}'." unless olist.length > 0

    sample_type_id = SampleType.find_by_name(spec[:of])
    raise "Could not find sample type named '#{spec[:of]}'." unless sample_type_id

    slist = Sample.where("name = ? AND sample_type_id = ?", name, sample_type_id)
    raise "Could not find sample named #{name}" unless slist.length > 0

    i.object_type_id = olist[0].id
    i.sample_id = slist[0].id

    i.location = olist[0].location_wizard project: i.sample.project
    i.quantity = 1
    i.inuse = 0
    i.save

    i

  end

end

