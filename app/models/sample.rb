class Sample < ActiveRecord::Base

  attr_accessible :field1, :field2, :field3, :field4, :field5, :field7, :field6, :field8, :name, :user_id, :project, :sample_type_id, :user_id, :description
  belongs_to :sample_type
  belongs_to :user
  has_many :items
  has_many :post_associations
  has_many :workflow_associations
  has_many :folder_contents

  validates_uniqueness_of :name, message: "Samples: must have unique names."

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

  def set_property name, val
    st = self.sample_type
    i = st.field_index name
    if i
      n = "field#{i}type"
      case st[n]
        when "url", "string"
          raise "Field '#{name}' should be a string" unless val.class == String
          self["field#{i}".to_sym] = val
        when "number"
          raise "Field '#{name}' should be a number" unless val.class == Fixnum || val.class == Float
          self["field#{i}".to_sym] = val          
        else
          if val.class == String
            s = Sample.find_by_name val
            raise "Could not find sample named #{val}" unless s
            self["field#{i}".to_sym] = val
          elsif val.class == Fixnum
            s = Sample.find_by_id val
            raise "Could not find sample with id #{val}" unless s
            self["field#{i}".to_sym] = s.name
          else
            raise "Field '#{name}' should be a sample id or a sample name" 
          end
      end
    else
      raise "Could not find field named #{name} in #{self.sample_type.name}"
    end
  end

  def properties
    st = sample_type
    result = {}
    (1..8).each do |i|
      n = "field#{i}name"
      t = "field#{i}type"
      if st[n] != nil
        case st[t]
          when "url", "string"
            result[st[n]] = self["field#{i}"]
          when "number"
            x = self["field#{i}"]
            if x.to_i == x.to_f
              result[st[n]] = x.to_i
            else
              result[st[n]] = x.to_f
            end
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
          self[f] ? self[f] : "-"
        elsif sample_type[ft] == 'string'
          s = self[f]
          if !s
            "-"
          elsif s.length > 20
            s[0,20] + '...'
          else
            s ? s : "?"
          end
        elsif self[f] == '-none-'
          "-"
        else
          l = Sample.find_by_name(self[f])
          if l
            "<a href='samples/#{l.id}'>#{l.name}</a>"
          else
            "-"
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

    ot = ObjectType.find_by_name(object_type_name)
    raise "Could not find object type #{name}" unless ot
    Item.make( { quantity: 1, inuse: 0 }, sample: self, object_type: ot )

  end

  def num_posts
    self.post_associations.count
  end

  def lite_properties

    st = SampleType.find(sample_type_id) # Note: Not using sample_type here because I don't want to
                                         # load the association in the case when it hasn't been included
                                         # by the user's request

    result = {}
    (1..8).each do |i|
      n = "field#{i}name"
      t = "field#{i}type"
      if st[n] != nil
        case st[t]
          when "url", "string"
            result[st[n]] = self["field#{i}"]
          when "number"
            x = self["field#{i}"]
            if x.to_i == x.to_f
              result[st[n]] = x.to_i
            else
              result[st[n]] = x.to_f
            end
          else
            s = Sample.find_by_name( self["field#{i}"] )
            if s
              result[st[n]] = s.id
            else
              result[st[n]] = nil
            end
          end
      end
    end
    return result
  end

  @@sample_types = false

  def really_lite_properties

    unless @@sample_types
      @@sample_types = []
      sts = SampleType.all.each do |st|
        @@sample_types[st.id] = st
      end
    end

    st = @@sample_types[self.sample_type_id]

    result = {}
    (1..8).each do |i|
      n = "field#{i}name"
      t = "field#{i}type"
      if st[n] != nil
        case st[t]
          when "url", "string"
            result[st[n]] = self["field#{i}"]
          when "number"
            x = self["field#{i}"]
            if x.to_i == x.to_f
              result[st[n]] = x.to_i
            else
              result[st[n]] = x.to_f
            end
          else
            result[st[n]] = self["field#{i}"]
          end
      end
    end
    return result
  end

  def export
    a = attributes
    a[:fields] = self.really_lite_properties
    (1..8).each do |i|
      a.delete "field#{i}"
    end
    a[:sample_type] = sample_type.export if association(:sample_type).loaded?    
    a
  end

  def self.okay_to_drop? sample, user

    warn "Could not find sample"                                                and return false unless sample
    warn "Not allowed to delete sample #{sample.id}"                            and return false unless sample.user_id == user.id
    warn "Could not delete sample #{sample.id} because it has associated items" and return false unless sample.items.length == 0

    true

  end

  def threads
    self.workflow_associations.collect { |wa| puts wa.inspect; wa.workflow_thread }
  end

  def for_folder
    s = as_json
    s[:sample_type] = { name: sample_type.name }  
    s[:fields] = ((1..8).select { |i| [ "number", "string", "url" ].member? sample_type["field#{i}type".to_sym] }).collect { |i|
      {
        name: sample_type["field#{i}name".to_sym],
        value: self["field#{i}".to_sym]
      }
    }
    s
  end

end
