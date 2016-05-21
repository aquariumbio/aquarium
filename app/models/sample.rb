class Sample < ActiveRecord::Base

  include ActionView::Helpers::DateHelper
  include SampleValidator

  attr_accessible :name, :user_id, :project, :sample_type_id, :user_id, :description
  attr_accessible :field1, :field2, :field3, :field4, :field5, :field7, :field6, :field8 # deprecated

  belongs_to :sample_type
  belongs_to :user
  has_many :items
  has_many :post_associations

  # Field values
  has_many :field_values

  validates_uniqueness_of :name, message: "The sample name '%{value}' is the name of an existing sample"

  validates :name, presence: true
  validates :project, presence: true
  validates :user_id, presence: true

  def self.sample_from_identifier str
    if str
      parts = str.split(': ')
      if parts.length > 1
        Sample.find_by_name(parts[1..-1].join(": "))
      else
        nil
      end
    else
      nil
    end
  end

  def self.creator raw, user

    sample = Sample.new
    sample.user_id = user.id    
    sample.sample_type_id = raw[:sample_type_id]
    sample.updater raw

    return sample

  end

  def stringify_errors elist
    elist.full_messages.join(",")
  end

  def updater raw, user=nil

    self.name = raw[:name]
    self.description = raw[:description]
    self.project = raw[:project]

    Sample.transaction do 

      save

      if errors.empty?

        sample_type = SampleType.find(raw[:sample_type_id])

        if raw[:field_values]

          raw[:field_values].each do |raw_fv|

            ft = sample_type.type(raw_fv[:name])

            if raw_fv[:id] && raw_fv[:deleted] 

              fv = FieldValue.find_by_id(raw_fv[:id])
              fv.destroy if fv

            elsif !raw_fv[:deleted] # fv might have been made and marked deleted without ever having been saved

              if raw_fv[:id]
                begin
                  fv = FieldValue.find(raw_fv[:id])            
                rescue Exception => e
                  errors.add :missing_field_value, "Field value #{raw_fv[:id]} not found in db."
                  errors.add :missing_field_value, e.to_s
                  raise ActiveRecord::Rollback
                end
              else
                fv = field_values.create(name: raw_fv[:name])
              end

              if ft.ftype == 'sample'
                if raw_fv[:new_child_sample]
                  child = Sample.creator(raw_fv[:new_child_sample], user ? user : User.find(self.user_id))
                else
                  child = Sample.sample_from_identifier raw_fv[:child_sample_name]
                end
                fv.child_sample_id = child.id if child
                if !child && ft.required
                  errors.add :required, "Sample required for field '#{ft.name}' not found or not specified."
                  raise ActiveRecord::Rollback
                end
                unless !child || child.errors.empty?
                  errors.add :child_error, "#{ft.name}: " + stringify_errors(child.errors)
                  raise ActiveRecord::Rollback  
                end
              elsif ft.ftype == 'number'
                fv.value = raw_fv[:value].to_f
              else # string, url 
                fv.value = raw_fv[:value]
              end

              fv.save

              unless fv.errors.empty? 
                errors.add :field_value, "Could not save field #{raw_fv[:name]}: #{stringify_errors(fv.errors)}"
                raise ActiveRecord::Rollback
              end

            end # if

          end # each

        end # if

      else 

        raise ActiveRecord::Rollback

      end

    end

  end

  #################################################################
  # Old methods for dealing with string valued fields

  def get_property key # deprecated
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

    ft = field_type name
    fvs = field_values.select { |fv| fv.name == name }

    if fvs.length == 0
      fvs = [ field_values.create(name: name) ]
    end

    if ft && fvs.length == 1

      fv = fvs[0]

      case field_type(name).ftype 
     
      when 'string', 'url'
        raise "#{val} is not a string" unless val.class == String
        fv.value = val

      when 'number'
        raise "#{val} is not a number" unless val.respond_to? :to_f
        fv.value = val.to_s
    
      when 'sample'
        raise "#{val} is not a sample" unless val.class == Sample
        fv.child_sample_id = val.id

      when 'item'
        raise "#{val} is not a item" unless val.class == Item
        fv.child_item_id = val.id

      end

      fv.save

    else 

      self.errors.add(:set_property,"Could not set sample #{id} property #{name} to #{val}")
      nil

    end

    # TODO: allow user to set array fields too

  end

  def properties
    p = {}
    field_values.each do |fv|
      if fv.value
        ft = field_type fv.name 
        if ft.ftype == 'number'
          p[fv.name] = fv.value.to_f
        else
          p[fv.name] = fv.value
        end
      elsif fv.child_sample_id
        p[fv.name] = fv.child_sample
      elsif fv.child_item_id
        p[fv.name] = fv.child_item
      end
    end
    p
  end

  def value field_type

    result = field_values.select { |fv| fv.name == field_type.name }

    if field_type.array
      result
    else
      if result.length >= 1
        result[0]
      else
        nil
      end
    end

  end

  def field_type name
    fts = sample_type.field_types.select { |ft| ft.name == name }
    if fts.length > 0
      fts[0]
    else
      nil
    end
  end

  def displayable_properties

    sample_type.field_types.collect do |ft|
      v = value ft
      if v.class == Array
        v.collect { |u| u.to_s }.join(", ")
      else
        v.to_s
      end
    end

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
    "<a href='/samples/#{self.id}' class='aquarium-item' id='#{self.id}'>#{self.id}</a>"
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

  def lite_properties # deprecated

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

  ####################################################################################################
  # UNUSED WORKFLOW STUFF FROM HERE TO EOF: OKAY TO EVENTUALLY DELETE 

  has_many :workflow_associations
  has_many :folder_contents

  def threads
    self.workflow_associations.collect { |wa| puts wa.inspect; wa.workflow_thread }
  end

  def data_hash
    JSON.parse(self.data,symbolize_names:true)
  end

  def for_folder_aux

    s = as_json
    s[:sample_type] = { name: sample_type.name }

    if self.data

      s["data"] = self.data_hash

    else

      s[:fields] = ((1..8).select { |i| [ "number", "string", "url" ].member? sample_type["field#{i}type".to_sym] }).collect { |i|
        {
          name: sample_type["field#{i}name".to_sym],
          value: self["field#{i}".to_sym]
        }
      }

      o = {}
      s[:fields].each do |f|
        o[f[:name]] = f[:value]
      end
      s["data"] = o
      self.data = o.to_json
      puts "saving\n\n\n"
      self.save

    end

    # Add any new fields defined by the sample_type, if necessary
    flag = false
    puts "sample_type.datatype_hash = #{sample_type.inspect}"
    sample_type.datatype_hash.each do |k,v|
      unless s["data"][k]
        flag = true
        s["data"][k.to_s] = v == "number" ? 0 : ""
      end
    end

    if flag
      self.data = s["data"].to_json
      self.save
    end

    s

  end

  def for_folder containing_thread_id=nil

    s = self.for_folder_aux

    s[:containing_thread_id] = containing_thread_id if containing_thread_id

    s[:threads] = self.workflow_associations
      .select { |wa| wa.thread && wa.thread.workflow }
      .collect { |wa|
        {
          id: wa.thread.id,
          user: User.find_by_id(wa.thread.user_id),
          workflow: {
            id: wa.thread.workflow.id,
            name: wa.thread.workflow.name
          },
          role: wa.role,
          process_id: wa.thread.workflow_process ? wa.thread.workflow_process.id : nil,
          updated_at: wa.thread.workflow_process ? time_ago_in_words(wa.thread.workflow_process.updated_at) : nil
        }
      }

    s

  end

  def to_workflow_identifier
    "#{self.id}: #{self.name}"
  end

  # def as_json opts={}
  #   j = super opts
  #   j[:properties] = properties.as_json
  #   j
  # end

end
