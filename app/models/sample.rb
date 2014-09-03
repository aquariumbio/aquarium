class Sample < ActiveRecord::Base

  attr_accessible :field1, :field2, :field3, :field4, :field5, :field7, :field6, :field8, :name, :user_id, :project, :sample_type_id, :user_id, :description
  belongs_to :sample_type
  belongs_to :user
  has_many :items

  validates_uniqueness_of :name, scope: :project, message: ": Samples within the same project must have unique names."

  validates :name, presence: true
  validates :project, presence: true
  validates :user_id, presence: true

  def get_property key
    # Look up fields according to sample type field structure
    st = sample_type
    (1..8).each do |i|
      n = "field#{i}name"
      if st[n] == key
        return self["field#{i}"]
      end
    end
    return nil
  end

  def properties
    st = sample_type
    result = {}
    (1..8).each do |i|
      n = "field#{i}name"
      t = "field#{i}type"
      if st[n] != nil
        case t
          when "url", "number", "string"
            result[st[n]] = self["field#{i}"]
          else
            result[st[n]] = Sample.find_by_name( self["field#{i}"] )
          end
      end
    end
    return result
  end

  def displayable_properties

    sample_type = self.sample_type

    result = (1..8).collect do |i| 

      fn = "field#{i}name".to_sym
      ft = "field#{i}type".to_sym 
      f = "field#{i}".to_sym

      if sample_type[ft] != 'not used' && sample_type[ft] != nil
        if sample_type[ft] == 'url'
          if self[f] != '' && self[f] != nil
            "<a href='#{self[f]}'>#{self[f][0..20]}...</a>"
          else
            "-"
          end
        elsif sample_type[ft] == 'number'
          self[f]
        elsif sample_type[ft] == 'string'
          s = self[f]
          if !s
            "-"
          elsif s.length > 20
            s[0,20] + '...'
          else
            s
          end
        elsif self[f] == '-none-'
          "-"
        else
          l = Sample.find_by_name(self[f])
          if l
            "<a href='samples/#{l.id}'>#{l.name}</a>"
          else
            "?"
          end
        end
      end

    end

    result.reject { |r| r == nil }

  end

  def in container

    c = ObjectType.find_by_name container
    if c
      Item.where("sample_id = ? AND object_type_id = ? AND NOT ( location = 'deleted' )", self.id, c.id )
    else
      []
    end

  end

  def to_s
    "<span class='aquarium-sample' id='#{self.id}'>#{self.id}</span>"
  end

  def owner
    u = User.find_by_id(self.user_id)
    if u
      u.login
    else
      '?'
    end
  end

  def make_item object_type_name

    olist = ObjectType.where("name = ?", object_type_name)
    raise "Could not find container named '#{spec[:as]}'." unless olist.length > 0

    i = Item.new
    i.sample_id = self.id
    i.object_type_id = olist[0].id

    i.location = olist[0].location_wizard project: self.project
    i.quantity = 1
    i.inuse = 0
    i.save

    i

  end

end
