class FieldType < ActiveRecord::Base

  include FieldTypePlanner

  belongs_to :sample_type
  has_many :allowable_field_types, dependent: :destroy
  has_many :field_values

  attr_accessible :parent_id, :array, :choices, :name, :required, :ftype, :role, :part

  validates :name, presence: true
  validates :ftype, presence: true  

  validates_inclusion_of :ftype, :in => [ "string", "number", "url", "sample", "item" ]

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

end 
