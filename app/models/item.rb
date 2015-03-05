class Item < ActiveRecord::Base

  # associations #######################################################

  belongs_to :object_type
  belongs_to :sample
  has_many :touches
  has_one :part
  has_many :cart_items
  has_many :takes
  has_one :locator, autosave: false
  has_many :post_associations

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
    if self.locator
      self.locator.to_s
    elsif primitive_location
      primitive_location
    else
      "Unknown"
    end
  end

  def location= x
    move_to x
    write_attribute(:location,x) # just for consistency
  end

  def set_primitive_location locstr
    write_attribute(:location,locstr) 
  end

  def store
    wiz = Wizard.find_by_name(object_type.prefix)
    if wiz
      locator = wiz.next
      move_to( wiz.int_to_location locator.number )
    end
  end

  def move_to locstr 

    if object_type
      wiz = Wizard.find_by_name(object_type.prefix)
    end

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
        puts "newloc = #{newloc.inspect}"
        newloc.reload

        errors.add(:locator_save_error, "Error: '#{errors.full_messages.join(',')}'") unless errors.empty? 

      else

        errors.add(:locator_taken, "Location taken by item #{newloc.item_id}.")

      end

    else # location is not in the form managed by a wizard

      loc = Locator.find_by_id(locator_id)
      loc.item_id = nil if loc
      
      write_attribute(:location,locstr)
      self.locator_id = nil

      transaction do
        self.save
        loc.save if loc
      end

      self.reload

    end

    self

  end

  def non_wizard_location?

    wiz = Wizard.find_by_name(self.object_type.prefix)

    if wiz && self.locator == nil
      return false
    else
      return true
    end

  end

  def move locstr # for backwards compatability
    move_to locstr
  end

  def self.make params, opts={} 

    # Make a new item with the specified object type and sample information.
    # This method creates a new locator if the object_type is associated with a
    # location wizard.

    o = { object_type: nil, sample: nil, location: nil }.merge opts

    if o[:object_type]
      item = self.new params.merge( object_type_id: o[:object_type].id )
    else 
      item = self.new params
    end

    if o[:sample]
      item.sample_id = o[:sample].id
    end

    if o[:object_type]
      item.object_type_id = o[:object_type].id
      wiz = Wizard.find_by_name(o[:object_type].prefix)
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
    Item.make( { quantity: 1, inuse: 0 }, object_type: olist[0] )

  end

  def self.new_sample name, spec

    raise "No Sample Type Specified (with :of)" unless spec[:of]
    raise "No Container Specified (with :in)" unless spec[:as]

    olist = ObjectType.where("name = ?", spec[:as])
    raise "Could not find container named '#{spec[:as]}'." unless olist.length > 0

    sample_type_id = SampleType.find_by_name(spec[:of])
    raise "Could not find sample type named '#{spec[:of]}'." unless sample_type_id

    slist = Sample.where("name = ? AND sample_type_id = ?", name, sample_type_id)
    raise "Could not find sample named #{name}" unless slist.length > 0

    Item.make( { quantity: 1, inuse: 0 }, sample: slist[0], object_type: olist[0] )

  end

  def num_posts
    self.post_associations.count
  end

  def export
    a = attributes
    a.delete "inuse"
    a.delete "locator_id"
    begin
      a["data"] = self.get_data
    rescue
    end
    a[:sample] = sample.export if association(:sample).loaded?
    a[:object_type] = object_type.export if association(:object_type).loaded?
    a
  end  

end

