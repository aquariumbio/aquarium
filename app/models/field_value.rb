# frozen_string_literal: true

# Simply put: a representation of an input, output, or parameter of an Operation.
#
# In more detail: an Item, Sample, or parameter of the inputs/outputs of an {Operation} or of the properties of a {Sample}
# that can be verified as allowed for that {Operation} or {Sample} by the corresponding {FieldType} of
# the respective parent {OperationType} or {SampleType}.
# @api krill

class FieldValue < ActiveRecord::Base

  include FieldValuePlanner
  include FieldValueKrill

  # belongs_to :sample # Not sure if this is used anywhere

  belongs_to :child_sample, class_name: 'Sample', foreign_key: :child_sample_id
  belongs_to :child_item, class_name: 'Item', foreign_key: :child_item_id
  belongs_to :allowable_field_type

  # Gets the {FieldType} which defines this field value.
  #
  # @return [FieldType]  the parent {FieldType}
  belongs_to :field_type

  # Gets name of FieldValue. Will be the same as the name of the Parent {FieldType}.
  #
  # @return [String]  the name of the FieldValue, as in "Forward Primer"
  attr_accessible :name

  attr_accessible :field_type_id, :row, :column, :allowable_field_type_id, :child_item_id, :child_sample_id, :value, :role
  attr_accessible :parent_class, :parent_id

  # Return associated {Sample}.
  #
  # @return [Sample]
  def sample
    child_sample
  end

  # Return associated {Item}.
  #
  # @return [Item]
  def item
    child_item
  end

  # Return an html link to the item ui for the {Item} associated with this field value.
  #
  # @return [String]
  def item_link
    if child_item_id
      child_item.to_s
    else
      '?'
    end
  end

  # Return associated {Collection}
  #
  # @return [Collection]
  def collection
    Collection.find(child_item.id) if child_item
  end

  # Return associated {Part} if this fv refers to a part of a collection
  #
  # @return [Item]
  def part
    collection_part row, column
  end

  # Return the specified part of collection
  #
  # @param row [Fixnum]
  # @param column [Fixnum]
  # @return [Item]
  def collection_part(row, column)
    pas = PartAssociation.where(collection_id: child_item_id, row: row, column: column)
    pas[0].part if pas.length == 1
  end

  # Return associated parameter value.
  #
  # @return [Float, String, Hash, Sample, Item] The value of the
  #   {FieldValue} of the type specified in the operation type
  #   definition
  def val

    if field_type
      ft = field_type
    elsif sample && sample_type
      fts = sample.sample_type.field_types.select { |type| type.name == name }
      return nil unless fts.length == 1

      ft = fts[0]
    else
      return nil
    end

    case ft.ftype
    when 'string', 'url'
      return value
    when 'json'
      begin
        return JSON.parse value, symbolize_names: true
      rescue JSON::ParserError => e
        return { error: e, original_value: value }
      end
    when 'number'
      return value.to_f
    when 'sample'
      return child_sample
    when 'item'
      return child_item
    end

  end

  def self.create_string(sample, ft, values)
    values.each do |v|
      if ft.choices && ft.choices != ''
        choices = ft.choices.split(',')
        unless choices.member? v
          sample.errors.add :choices, "#{v} is not a valid choice for #{ft.name}"
          raise ActiveRecord::Rollback
        end
      end
      fv = sample.field_values.create name: ft.name, value: v
      fv.save
    end
  end

  def self.create_number(sample, ft, values)
    values.each do |v|
      if ft.choices && ft.choices != ''
        choices = ft.choices.split(',').collect(&:to_f)
        unless choices.member? v.to_f
          sample.errors.add :choices, "#{v} is not a valid choice for #{ft.name}"
          raise ActiveRecord::Rollback
        end
      end
      fv = sample.field_values.create name: ft.name, value: v.to_f
      fv.save
    end
  end

  def self.create_url(sample, ft, values)
    values.each do |v|
      fv = sample.field_values.create name: ft.name, value: v
      fv.save
    end
  end

  def self.create_sample(sample, ft, values)

    values.each do |v|

      if v.class == Sample
        child = v
      elsif v.class == Integer
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

  def self.creator(sample, field_type, raw) # sample, field_type, raw_field_data

    values = []
    if field_type.array
      if raw.class != Array
        sample.errors.add :array, "#{field_type.name} should be an array."
        raise ActiveRecord::Rollback
      end
      values = raw
    else
      values = [raw]
    end

    method('create_' + field_type.ftype).call(sample, field_type, values)

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

  def export
    attributes.merge(
      child_sample: child_sample.as_json,
      child_item: child_item.as_json
    )
  end

  def child_data(name)
    child_item.get(name) if child_item_id
  end

  def set_child_data(name, value)
    child_item.associate(name, value) if child_item_id
  end

  # Set {Item}, {Collection}, or row or column.
  #
  # @param opts [Hash]
  # @option opts [Item] :item
  # @option opts [Collection] :collection
  # @option opts [Integer] :row
  # @option opts [Integer] :column
  # @example For debugging, set input to specific plate
  #  if debug
  #    plate = Item.find(125234)
  #    operations.first.input("Plate").set item: plate if plate
  #  end
  def set(opts = {})
    self.child_item_id = opts[:item].id if opts[:item]
    self.child_item_id = opts[:collection].id if opts[:collection]
    self.row = opts[:row] if opts[:row]
    self.column = opts[:column] if opts[:column]
    save
  end

  def copy_inventory(fv)
    self.child_item_id = fv.child_item_id
    self.row = fv.row
    self.column = fv.column
    save
  end

  def routing
    ft = field_type
    ft ? ft.routing : nil
  end

  def full_json(_options = {})
    as_json(include: [
              :child_sample,
              :wires_as_source,
              :wires_as_dest,
              allowable_field_type: {
                include: %i[
                  object_type
                  sample_type
                ]
              }
            ])
  end

end
