
class FieldType < ActiveRecord::Base

  belongs_to :sample_type
  has_many :allowable_field_types, dependent: :destroy

  attr_accessible :array, :choices, :name, :required, :ftype

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

  def type
    ftype
  end

  def as_json(options={})
    super include: [ allowable_field_types: { include: :sample_type } ]
  end

end 
