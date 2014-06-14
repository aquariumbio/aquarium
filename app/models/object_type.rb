class ObjectType < ActiveRecord::Base

  attr_accessible :cleanup, :data, :description, :handler, :max, :min, :name, :safety, 
                  :vendor, :unit, :image, :cost, :release_method, :release_description,
                  :sample_type_id, :created_at, :prefix

  validates :name, :presence => true
  validates :unit, :presence => true
  validates :min, :presence => true
  validates :max, :presence => true
  validates :release_method, :presence => true
  validates :description, :presence => true
  validate :min_and_max
  validates :cost, :presence => true
  validate :pos
  validate :proper_release_method
  validates_uniqueness_of :name

  def min_and_max
    errors.add(:min, "min must be greater than zero and less than or equal to max") unless
      self.min && self.max && self.min >= 0 && self.min <= self.max
  end

  def pos
    errors.add(:cost, "must be at least $0.01" ) unless
      self.cost && self.cost >= 0.01
  end

  def proper_release_method
    errors.add(:release_method, "must be either return, dispose, or query") unless
      self.release_method && ( self.release_method == 'return'  || 
                               self.release_method == 'dispose' || 
                               self.release_method == 'query' )
  end

  has_many :items, dependent: :destroy
  belongs_to :sample_type

  def quantity
    q = 0
    self.items.each { |i|
      if i.quantity >= 0 
        q += i.quantity
      end
    }
    return q
  end

  def in_use
    q = 0
    self.items.each { |i|
      q += i.inuse
    }
    return q
  end

  def save_as_test_type name

    self.name = name
    self.handler = "temporary"
    self.unit = 'object'
    self.min = 0
    self.max = 100
    self.safety = "No safety information"
    self.cleanup = "No cleanup information"
    self.data = "No data"
    self.vendor = "No vendor information"
    self.cost = 0.01
    self.release_method = "return"
    self.description = "An object type made on the fly."
    self.save
    i = self.items.new
    i.quantity = 1000
    i.inuse = 0
    i.location = 'A0.000'
    i.save

  end

  ##############################################################################################################
  #
  #  Location Wizard for Freezers
  #

  def next_empty_box params

    r = Regexp.new ( params[:prefix] + '\.[0-9]+\.[0-9]+\.[0-9]+' )

    items = (ObjectType.where("prefix = ?", params[:prefix]).collect { |ot| ot.items }).flatten.reject { |i| 
      r.match(i.location) == nil 
    }

    if items.length == 0
      "0.0"
    else
      box = (items.collect { |i| 
        loc = i.location.split('.')
        [ loc[1].to_i, loc[2].to_i ]
      }).sort.last

      if box[1] == params[:boxes_per_hotel] - 1
        "#{box[0]+1}.0"
      else
        "#{box[0]}.#{box[1]+1}"      
      end
   end

  end

  def boxes_for_project params

    # 
    # Finds all boxes associated with the project params[:project]
    #
    # Returns a hash of the form boxname => array where boxname is like "M20.4.5" and array is an array
    # of the items in the box, with nil entries if there is no item in that slot.
    #

    # boxes will contain the results
    boxes = {}

    # a regexp to match locations of the right format
    r = Regexp.new ( params[:prefix] + '\.[0-9]+\.[0-9]+\.[0-9]+' )

    # all items
    items = Item.includes(:sample).includes(:object_type).all

    # all items with the same project
    related_items = items.select { |i| 
      r.match(i.location) != nil && i.sample && i.sample.project == params[:project] 
    }

    # figure out the boxes in the project
    related_items.each do |i|
      freezer,hotel,box,slot = i.location.split('.')
      slot = slot.to_i
      name = "#{freezer}.#{hotel}.#{box}"
      if !boxes[name]
        boxes[name] = Array.new(81) {nil}
      end
    end

    # figure out which items in are in which slots
    items.each do |i|

      freezer,hotel,box,slot = i.location.split('.')
      slot = slot.to_i
      name = "#{freezer}.#{hotel}.#{box}"

      if boxes[name]
        boxes[name][slot] = i.id
      end

    end

    boxes

  end

  def next_freezer_box_slot params

    # make list of all boxes associated with project
    boxes = boxes_for_project params

    # find first slot in a box with an empty slot
    boxes.each do |name,slots|
      for i in 0..80
        if slots[i] == nil
          return "#{name}.#{i}"
        end
      end
    end

    # choose a new box if all slots are full in all boxes for project
    p = { boxes_per_hotel: 16 }.merge params
    return "#{p[:prefix]}.#{next_empty_box p}.0"

  end

  def location_wizard details = {}

    params = { prefix: prefix, project: 'unknown' }.merge details

    case prefix
    
      when 'M20', 'M80', 'DFS'
        next_freezer_box_slot params

      when /^SF[0-9]/
        next_freezer_box_slot ( { boxes_per_hotel: 24 }.merge params )

      when /^FIX*/
        prefix.split(":").last

      when 'DFP' # Deli frig plate
        'DFP.0.0.0'

      else
        "Bench"

    end

  end

end


 
