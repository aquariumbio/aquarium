# typed: false
# frozen_string_literal: true

# @api krill
module FieldValuer

  def destroy_fields
    field_values.destroy_all
  end

  def field_values
    FieldValue.includes(:child_sample, :allowable_field_type, wires_as_dest: :to, wires_as_source: :from)
              .where(parent_class: self.class.to_s, parent_id: id)
  end

  def full_field_values
    FieldValue.includes(:child_sample, :allowable_field_type, wires_as_dest: :to, wires_as_source: :from)
              .where(parent_class: self.class.to_s, parent_id: id)
              .collect(&:full_json)
  end

  # Sets the value of the field value.
  # Adds an error if the field type is inconsistent with the type of the value.
  #
  # @param ft [FieldType] the field type
  # @param fv [FieldValue] the field value to set
  # @param val [String, Number, Sample, Item] the value
  # @return [FieldValue] the field value with the value set
  def set_value(field_type, field_value, value)
    # puts "SETTING #{fv.name}(#{fv.role}) to #{val.inspect}"

    case field_type.type
    when 'string', 'url', 'json'
      errors.add(:set_property, "#{value} is not a string") unless value.is_a?(String)
      field_value.value = value

    when 'number'
      errors.add(:set_property, "#{value} is not a number") unless value.respond_to? :to_f
      field_value.value = value.to_s

    when 'sample'
      if value&.is_a?(Sample)
        field_value.child_sample_id = value.id
      elsif value&.is_a?(Item)
        field_value.child_sample_id = value.sample_id
        field_value.child_item_id = value.id
      else
        # TODO: should probably raise exception
        errors.add(:set_property, "#{value} is not a sample or item") if value
        # this is used for empty samples in the planner
        field_value.child_sample_id = nil
      end

    when 'item'
      # NOTE: this is dead code. It never happens that ftype is 'item'
      #       but leaving it here just in case I'm wrong
      errors.add(:set_property, "#{value} is not a item") unless value.is_a?(Item)
      field_value.child_item_id = value.id
    end

    field_value
  end

  # Changes a property in the property hash for this object.
  #
  # @param name [String]  the name of property to overwrite
  # @param val [Array, Number, Sample, String, Item]  the new value of the property
  def set_property(name, val, role = nil, override_array = false, aft = nil)
    ft = field_type(name, role)

    unless ft
      errors.add(:no_such_property, "#{self.class} #{id} does not have a property named #{name} with role #{role}.")
      return self
    end

    fvs = field_values.select { |fv| fv.name == name && fv.role == role }

    if ft.array && val.is_a?(Array)
      val = val.first if val.any? { |v| v.is_a?(Array) }
      new_fvs = val.collect do |v|
        fv = set_value(ft, field_values.create(name: name, field_type_id: ft.id, role: role), v)
        fv.allowable_field_type_id = aft.id if aft
        fv
      end

      if errors.empty?
        new_fvs.each(&:save)
        fvs.each(&:destroy)
      end
    elsif ft.array && !val.is_a?(Array) && !override_array
      errors.add(:set_property, "Tried to set property #{ft.name}, an array, to something that is not an array.")
    elsif !ft.array && val.is_a?(Array)
      errors.add(:set_property, "Tried to set property #{ft.name}, which is not an array, to something is an array.")
    elsif !ft.array || override_array
      fvs = [field_values.create(name: name, field_type_id: ft.id, role: role)] if fvs.empty?

      if ft && fvs.length == 1
        fv = set_value(ft, fvs[0], val)
        fv.allowable_field_type_id = aft.id if aft
      else
        errors.add(:set_property, "Could not set #{self.class} #{id} property #{name} to #{val}")
        return self
      end

      if errors.empty?
        fv.save
        Rails.logger.info "Could not save field value #{fv.inspect}: #{fv.errors.full_messages.join(', ')}" unless fv.errors.empty?
      else
        Rails.logger.info "Errors setting property of #{self.class} #{id}: #{errors.full_messages.join(', ')}"
      end
    else
      Rails.logger.info "Could not set #{self.class} #{id} property #{name} to #{val}. No case matches conditions."
      errors.add(:set_property, "Could not set #{self.class} #{id} property #{name} to #{val}. No case matches conditions.")
    end

    self
  end

  # TODO: this should be a FieldValue method
  def basic_value(ft, fv)
    if fv.value
      ft = field_type fv.name
      if ft.number?
        fv.value.to_f
      else
        fv.value
      end
    elsif fv.child_sample_id
      fv.child_sample
    elsif fv.child_item_id
      fv.child_item
    end
  end

  # Property hash which keeps track of important information.
  #
  # @return [Hash]  hash of property keys and values for this model
  def properties
    p = {}

    parent_type.field_types.each do |ft|
      values = field_values.select { |fv| fv.name == ft.name }.collect { |fv| basic_value ft, fv }

      if ft.array
        p[ft.name] = values
      elsif values.length == 1
        p[ft.name] = values[0]
      end
    end

    p
  end

  def value(field_type)
    result = field_values.select { |fv| fv.name == field_type.name }

    return result if field_type.array
    return result.first if result.length >= 1
  end

  def field_type(name, role = nil)
    fts = parent_type.field_types.select { |ft| ft.name == name && ft.role == role }

    fts.first
  end

  def displayable_properties

    parent_type.field_types.collect do |ft|
      v = value ft
      if v.is_a?(Array)
        v.collect(&:to_s).join(', ')
      else
        v.to_s
      end
    end

  end

end
