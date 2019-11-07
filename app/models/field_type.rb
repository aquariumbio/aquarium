# frozen_string_literal: true

# Meta type of {FieldValue}.
# An Item type, or parameter type of the inputs/outputs of an {OperationType} or of the properties of a {SampleType}.
# FieldType holds a list of allowable values or objects for defining {Operation}s or {Sample}s
# that would satisfy the specifications of their respective abstract {OperationType} or {SampleType}.
# @api krill
class FieldType < ApplicationRecord

  include FieldTypePlanner

  belongs_to :sample_type
  has_many :allowable_field_types
  has_many :field_values
  has_one :preferred_operation_type
  has_one :preferred_field_type

  # Gets name of FieldType.
  #
  # @return [String]  the name of the FieldValue, as in "Forward Primer"
  attr_accessible :name

  # Gets the id of the object to which this FieldType belongs.
  #
  # @return [Fixnum]  {Operation} or {Sample} id
  attr_accessible :parent_id

  # Gets the name of the class of the object to which this FieldType belongs.
  #
  # @return [String]  class of parent object, as in "SampleType"
  attr_accessible :parent_class

  attr_accessible :array, :choices, :required, :ftype, :role, :part, :routing
  attr_accessible :preferred_operation_type_id, :preferred_field_type_id

  validates :name, presence: true
  validates :ftype, presence: true

  validates :ftype, inclusion: { in: %w[string number url sample item json] }

  def destroy
    allowable_field_types.each(&:destroy)
    super
  end

  # Check whether the given value is allowed by this field type.
  #
  # @param val [Object]  the potential value to check
  # @return [Boolean]  whether or not the value would be allowed
  def allowed?(val)
    case ftype
    when 'string', 'url'
      val.is_a?(String)
    when 'number'
      val.is_a?(Integer) || val.is_a?(Float)
    when 'sample'
      allowable_field_types.collect { |aft| aft.sample_type.id }.member? val.sample_type_id
    when 'item'
      allowable_field_types.collect { |aft| aft.object_type.id }.member? val.object_type_id
    end
  end

  def allowable_sample_types
    if sample?
      allowable_field_types.collect(&:sample_type)
    else
      []
    end
  end

  def has_sample_type
    sample_types = allowable_sample_types.select { |st| st }
    !sample_types.empty?
  end

  def allowable_object_types
    if item?
      allowable_field_types.collect(&:object_type)
    else
      []
    end
  end

  def type
    ftype
  end

  def has_type(typename)
    ftype == typename
  end

  def string?
    has_type('string')
  end

  def sample?
    has_type('sample')
  end

  def number?
    has_type('number')
  end

  def json?
    has_type('json')
  end

  def item?
    has_type('item')
  end

  def empty?
    allowable_sample_types.select { |ast| ast }.empty?
  end

  def as_json(options = {})
    if options[:plain]
      super
    else
      super include: [allowable_field_types: { include: %i[sample_type object_type] }]
    end
  end

  def inconsistencies(raw_field_type, parent_name)

    results = []

    results << "#{parent_name} field '#{name}' and imported field #{raw_field_type[:name]} should match." unless raw_field_type[:name] == name
    results << "#{parent_name} field '#{name}' has different choices than important field with same name" unless raw_field_type[:choices] == choices
    results << "#{parent_name} field '#{name}' has array = #{!!array} but imported field of the same name has array = #{!!raw_field_type[:array]}." unless !!raw_field_type[:array] == !!array
    unless !!raw_field_type[:part] == !!part
      # TODO: make sure the following line is correct.  previously had a && at the end
      results << "#{parent_name} field '#{name}' has required = #{!!required} but imported field of the same name has required = #{!!raw_field_type[:required]}." unless !!raw_field_type[:required] == !!required
      results << "#{parent_name} field '#{name}' has part = #{!!part} but imported field of the same name has part = #{!!raw_field_type[:part]}."
    end
    results << "#{parent_name} field '#{name}' has type is #{!!ftype} but imported field of the same name has type = #{!!raw_field_type[:ftype]}." unless raw_field_type[:ftype] == ftype
    results << "#{parent_name} field '#{name}' has role is #{!!role} but imported field of the same name has role = #{!!raw_field_type[:role]}" unless raw_field_type[:role] == role
    results << "#{parent_name} field '#{name}' has routing symbol is #{!!routing} but imported field of the same name has routing symbol = #{!!raw_field_type[:routing]}." unless raw_field_type[:role] == role

    if sample?

      l1 = allowable_field_types.collect do |aft|
        [
          aft.sample_type ? aft.sample_type.name : nil,
          aft.object_type ? aft.object_type.name : nil
        ]
      end

      a = raw_field_type[:sample_types] || []
      b = raw_field_type[:object_types] || []
      l2 = a.zip b

      results << "#{parent_name}: Field '#{name}'' has different associated sample and object types than does the imported field by the same name." unless l1.conjoin { |x| l2.member? x } && l2.conjoin { |x| l1.member? x }

    end

    results

  end

  # Creates a hash for this field_type.
  def export
    {
      ftype: type,
      role: role,
      name: name,
      sample_types: allowable_field_types.collect { |aft| aft.sample_type ? aft.sample_type.name : nil },
      object_types: allowable_field_types.collect { |aft| aft.object_type ? aft.object_type.name : nil },
      part: part ? true : false,
      array: array ? true : false,
      routing: routing,
      preferred_operation_type_id: preferred_operation_type_id,
      preferred_field_type_id: preferred_field_type_id,
      choices: choices
    }
  end

end
