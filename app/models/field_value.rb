class FieldValue < ActiveRecord::Base

  include FieldValuePlanner
  include FieldValueKrill

  # belongs_to :sample # Not sure if this is used anywhere
  belongs_to :child_sample, class_name: "Sample", foreign_key: :child_sample_id
  belongs_to :child_item, class_name: "Item", foreign_key: :child_item_id  
  belongs_to :field_type
  belongs_to :allowable_field_type

  attr_accessible :name, :child_item_id, :child_sample_id, :value, :role, :field_type_id, :item, :row, :column

  validate :valid

  def valid

    unless field_type_id
      errors.add(:field_type, "No field type specified for #{role} '#{name}'")
      return false
    end

    if field_type.ftype == 'sample'

      Rails.logger.info "--------------------- #{child_item_id}"

      unless child_sample_id
        errors.add(:child_sample, "No sample specified for #{role} '#{name}'")
        return false
      end

    end

    return true

  end

  def sample
    child_sample
  end

  def item
    child_item
  end

  def collection
    child_item
  end

  def val

    if field_type
      ft = field_type
    elsif self.sample && self.sample_type
      fts = self.sample.sample_type.field_types.select { |ft| ft.name == self.name }
      if fts.length == 1
        ft = fts[0]
      else
        return nil
      end
    else
      return nil
    end

    case ft.ftype
    when 'string', 'url'
      return self.value
    when 'number'
      return self.value.to_f
    when 'sample'
      return self.child_sample
    when 'item'
      return self.child_item
    end

  end

  def self.create_string sample, ft, vals
    vals.each do |v|
      if ft.choices && ft.choices != ""
        choices = ft.choices.split(",")
        unless choices.member? v
          sample.errors.add :choices, "#{v} is not a valid choice for #{ft.name}"
          raise ActiveRecord::Rollback                    
        end
      end
      fv = sample.field_values.create name: ft.name, value: v
      fv.save
    end
  end

  def self.create_number sample, ft, vals
    vals.each do |v|
      if ft.choices && ft.choices != ""
        choices = ft.choices.split(",").collect { |c| c.to_f }
        unless choices.member? v.to_f
          sample.errors.add :choices, "#{v} is not a valid choice for #{ft.name}"
          raise ActiveRecord::Rollback                    
        end
      end
      fv = sample.field_values.create name: ft.name, value: v.to_f
      fv.save
    end 
  end

  def self.create_url sample, ft, vals
    vals.each do |v|
      fv = sample.field_values.create name: ft.name, value: v
      fv.save
    end 
  end

  def self.create_sample sample, ft, vals

    vals.each do |v|

      if v.class == Sample
        child = v
      elsif v.class == Fixnum
        child = Sample.find_by_id(v)
        unless sample
          sample.errors.add :sample, "Could not find sample with id #{v} for #{ft.name}"
          raise ActiveRecord::Rollback  
        end
      else
        sample.errors.add :sample, "#{v} should be a sample for #{ft.name}"
        raise ActiveRecord::Rollback  
      end

      unless ft.allowed? child
        sample.errors.add :sample, "#{v} is not an allowable sample_type for #{ft.name}"
        raise ActiveRecord::Rollback
      end

      fv = sample.field_values.create name: ft.name, child_sample_id: child.id
      fv.save
    end  
  end

  def self.create_item sample, ft, vals
    vals.each do |v|
      if v.class == Item
        item = v
      elsif v.class == Fixnum
        item = Item.find(v)
        unless item
          sample.errors.add :item, "Could not find item with id #{v} for #{ft.name}"
          raise ActiveRecord::Rollback  
        end                
      else
        sample.errors.add :sample, "#{v} should be an item for #{ft.name}"
        raise ActiveRecord::Rollback  
      end    

      unless ft.allowed? child
        sample.errors.add :sample, "#{v} is not an allowable sample_type for #{ft.name}"
        raise ActiveRecord::Rollback
      end  

      fv = sample.field_values.create name: ft.name, child_item_id: sid
      fv.save
    end 
  end

  def self.creator sample, field_type, raw # sample, field_type, raw_field_data

    vals = []
    if field_type.array
      if raw.class != Array
        sample.errors.add :array, "#{field_type.name} should be an array."
        raise ActiveRecord::Rollback              
      end
      vals = raw
    else
      vals = [ raw ]
    end

    self.method("create_"+field_type.ftype).call(sample,field_type,vals)

  end

  def to_s
    if child_sample_id
      c = Sample.find_by_id(child_sample_id)
      if c
        "<a href='/samples/#{c.id}'>#{c.name}</a>"
      else
        "? #{child_sample_id} not found ?"
      end
    elsif child_item_id
      c = Item.includes(:object_type).find_by_id(child_sample_id)
      if c
        "<a href='/items/#{c.id}'>#{c.object_type.name} #{c.id}</a>"
      else
        "? #{child_item_id} not found ?"
      end
    else
      value
    end

  end

  def as_json(options={})
    super(include: [ :child_sample, allowable_field_type: { include: [ :object_type, :sample_type ]} ], methods: [ :wires_as_source, :wires_as_dest ] )
  end

  def export
    attributes.merge({
      child_sample: child_sample.as_json,
      child_item: child_item.as_json,      
    })
  end

  def child_data name
    if child_item_id
      child_item.get(name)
    else
      nil
    end
  end

  def set_child_data name, value
    if child_item_id
      child_item.associate name, value
    else
      nil
    end
  end

  def set opts={}
    self.child_item_id = opts[:item].id if opts[:item]   
    self.child_item_id = opts[:collection].id if opts[:collection]
    self.row = opts[:row] if opts[:row]
    self.column = opts[:column] if opts[:column]
    self.save
  end

  def copy_inventory fv
    self.child_item_id = fv.child_item_id 
    self.row = fv.row
    self.column = fv.column
    self.save    
  end

  def routing
    ft = field_type
    ft ? ft.routing : nil
  end

end 
