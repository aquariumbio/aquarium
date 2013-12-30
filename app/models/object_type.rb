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
      q += i.quantity
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

  def next_empty_box prefix

    items = (ObjectType.where("prefix = ?", prefix).collect { |ot| ot.items }).flatten.reject { |i| 
      /M[2,8]0\.[0-9]+\.[0-9]+\.[0-9]+/.match(i.location) == nil 
    }

    if items.length == 0
      "0.0"
    else
      box = (items.collect { |i| 
        loc = i.location.split('.')
        [ loc[1].to_i, loc[2].to_i ]
      }).sort.last

      if box[1] == 15
        "#{box[0]+1}.0"
      else
        "#{box[0]}.#{box[1]+1}"      
      end
   end

  end

  def sort_locations locs 

    locs.sort do |a,b|
      x = a.split('.')
      y = b.split('.')
      if x[1].to_i != y[1].to_i
        x[1].to_i - y[1].to_i
      elsif x[2].to_i != y[1].to_i
        x[2].to_i - y[2].to_i
      else 
        x[3].to_i - y[3].to_i
      end
    end

  end

  def next_location locs, prefix

    puts "LOCS = #{locs}"

    if locs.length == 0 # a totally new project!

      "#{prefix}.#{next_empty_box prefix}.0"

    else # an existing project

      x = (sort_locations locs).last.split('.')

      if x[3].to_i == 99 
        "#{prefix}.#{next_empty_box prefix}.0"
      else
        "#{x[0]}.#{x[1]}.#{x[2]}.#{x[3].to_i+1}"
      end

    end

  end

  def items_in_project prefix, project

    objects = ObjectType.where("prefix = ?", prefix)

    (objects.collect { |ot| 
      ot.items.reject { |i|
         /M[2,8]0\.[0-9]+\.[0-9]+\.[0-9]+/.match(i.location) == nil ||
         i.sample.project != project
      } 
    }).flatten.collect{ |i| 
      i.location
    }
  
  end

  def location_wizard details = {}

    info = { project: 'unknown' }.merge details

    case prefix
    
      when 'M20'
        next_location( (items_in_project 'M20', details[:project]), 'M20' )

      when 'M80'
        next_location( (items_in_project 'M80', details[:project]), 'M80' )

      else
        "Bench"

    end

  end

end


 
