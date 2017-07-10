class FieldType < ActiveRecord::Base

  include FieldTypePlanner

  belongs_to :sample_type
  has_many :allowable_field_types
  has_many :field_values
  has_one :preferred_operation_type
  has_one :preferred_field_type

  attr_accessible :parent_id, :parent_class, :array, :choices, :name, :required, :ftype, :role, :part, :routing
  attr_accessible :preferred_operation_type_id, :preferred_field_type_id

  validates :name, presence: true
  validates :ftype, presence: true  

  validates_inclusion_of :ftype, :in => [ "string", "number", "url", "sample", "item", "json" ]

  def destroy
    allowable_field_types.each do |aft|
      aft.destroy
    end
    super
  end

  def allowed? val
    case ftype
    when "string", "url"
      return val.class == String
    when "number"
      return val.class == Fixnum || val.class == Float
    when "sample"
      return allowable_field_types.collect { |aft| aft.sample_type.id }.member? val.sample_type_id
    when "item"
      return allowable_field_types.collect { |aft| aft.object_type.id }.member? val.object_type_id      
    end
  end

  def allowable_sample_types
    if ftype == "sample"
      allowable_field_types.collect { |aft| aft.sample_type }
    else
      []
    end
  end

  def has_sample_type
    asts = allowable_sample_types.select { |st| st }
    !asts.empty?
  end

  def allowable_object_types
    if ftype == "item"
      allowable_field_types.collect { |aft| aft.object_type }
    else
      []
    end
  end

  def type
    ftype
  end

  def empty?
    allowable_sample_types.select { |ast| ast }.length == 0
  end

  def as_json(options={})
    super include: [ allowable_field_types: { include: [ :sample_type, :object_type ] } ]
  end

  def inconsistencies raw_field_type, parent_name

    results = []

    results << "#{parent_name} field '#{name}' and imported field #{raw_field_type[:name]} should match." unless raw_field_type[:name] == name 
    results << "#{parent_name} field '#{name}' has different choices than important field with same name" unless raw_field_type[:choices] == choices
    results << "#{parent_name} field '#{name}' has array = #{!!array} but imported field of the same name has array = #{!!raw_field_type[:array]}." unless !!raw_field_type[:array] == !!array
    results << "#{parent_name} field '#{name}' has required = #{!!required} but imported field of the same name has required = #{!!raw_field_type[:required]}." unless !!raw_field_type[:required] == !!required &&
    results << "#{parent_name} field '#{name}' has part = #{!!part} but imported field of the same name has part = #{!!raw_field_type[:part]}." unless !!raw_field_type[:part] == !!part 
    results << "#{parent_name} field '#{name}' has type is #{!!ftype} but imported field of the same name has type = #{!!raw_field_type[:ftype]}." unless raw_field_type[:ftype] == ftype 
    results << "#{parent_name} field '#{name}' has role is #{!!role} but imported field of the same name has role = #{!!raw_field_type[:role]}" unless raw_field_type[:role] == role
    results << "#{parent_name} field '#{name}' has routing symbol is #{!!routing} but imported field of the same name has routing symbol = #{!!raw_field_type[:routing]}." unless raw_field_type[:role] == role

    if ftype == 'sample'

      l1 = allowable_field_types.collect { |aft| [
        aft.sample_type ? aft.sample_type.name : nil, 
        aft.object_type ? aft.object_type.name : nil 
      ] }

      a = raw_field_type[:sample_types] || []
      b = raw_field_type[:object_types] || []
      l2 = a.zip b

      if ! ( l1.conjoin { |x| l2.member? x } && l2.conjoin { |x| l1.member? x } )
        results << "#{parent_name}: Field '#{name}'' has different associated sample and object types than does the imported field by the same name." 
      end

    end

    return results

  end

end 
