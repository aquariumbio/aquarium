# A named, biologically unique definition for an instance of a {SampleType}, such as a specific Primer, Fragment, Plasmid, or Yeast Strain

class Sample < ActiveRecord::Base

  include ActionView::Helpers::DateHelper
  include SampleValidator

  include FieldValuer
  def parent_type # interface with FieldValuer
    sample_type
  end

  after_destroy :destroy_fields

  attr_accessible :name, :user_id, :project, :sample_type_id, :user_id, :description

  belongs_to :sample_type
  belongs_to :user
  has_many :items
  has_many :post_associations

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

            if ft && raw_fv[:id] && raw_fv[:deleted] 

              fv = FieldValue.find_by_id(raw_fv[:id])
              fv.destroy if fv

            elsif ft && !raw_fv[:deleted] # fv might have been made and marked deleted without ever having been saved

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
                fv.child_sample_id = nil if !child && raw_fv[:child_sample_name] == ""
                if !child && ft.required && raw_fv[:child_sample_name] != ""
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

              puts "before fv saved: {fv.inspect}"
              fv.save
              puts "fv saved. now #{fv.inspect}"

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

  # Return all items of this {Sample} in the provided {ObjectType}
  # @param container [String] {ObjectType} name
  # @example Find a 1 kb ladder for gel electrophoresis
  #   ladder_1k = Sample.find_by_name("1 kb Ladder").in("Ladder Aliquot")
  # @return [Array<Item>]
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

  # Return {User} who owns this {Sample}
  # @return [User]
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

  def self.okay_to_drop? sample, user

    warn "Could not find sample"                                                and return false unless sample
    warn "Not allowed to delete sample #{sample.id}"                            and return false unless sample.user_id == user.id
    warn "Could not delete sample #{sample.id} because it has associated items" and return false unless sample.items.length == 0

    true

  end

  def data_hash
    JSON.parse(self.data,symbolize_names:true)
  end

  def full_json

    sample_hash = self.as_json(
            include: { sample_type: { include: :object_types, methods: :field_types } },
            methods: :full_field_values
          )

    # rename field for compatibility with ng-control/sample.js
    sample_hash[:field_values] = sample_hash.delete :full_field_values 

    sample_hash
      
  end   

end
