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

  def set_property_aux(ft, fv, val)

    # puts "SETTING #{fv.name}(#{fv.role}) to #{val.inspect}"

    case ft.ftype

    when 'string', 'url', 'json'
      errors.add(:set_property, "#{val} is not a string") unless val.is_a?(String)
      fv.value = val

    when 'number'
      errors.add(:set_property, "#{val} is not a number") unless val.respond_to? :to_f
      fv.value = val.to_s

    when 'sample'
      if val
        errors.add(:set_property, "#{val} is not a sample") unless val.is_a?(Sample)
        fv.child_sample_id = val.id
      else
        fv.child_sample_id = nil # this is used for empty samples in the planner
      end

    when 'item'
      errors.add(:set_property, "#{val} is not a item") unless val.is_a?(Item)
      fv.child_item_id = val.id

    end

    fv

  end

  # Changes a property in the property hash for this object.
  #
  # @param name [String]  the name of property to overwrite
  # @param val [Object]  the new value of the property
  def set_property(name, val, role = nil, override_array = false, aft = nil)

    ft = field_type name, role

    unless ft
      errors.add(:no_such_property, "#{self.class} #{id} does not have a property named #{name} with role #{role}.")
      return self
    end

    fvs = field_values.select { |fv| fv.name == name && fv.role == role }

    if ft.array && val.is_a?(Array)
      if (val.any? { |v| v.is_a?(Array) })
        val = val.first
      end
      new_fvs = val.collect do |v|
        fv = set_property_aux(ft, field_values.create(name: name, field_type_id: ft.id, role: role), v)
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
        fv = set_property_aux(ft, fvs[0], val)
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

  def basic_value(ft, fv)

    if fv.value

      ft = field_type fv.name

      if ft.ftype == 'number'
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
      else
        p[ft.name] = values[0] if values.length == 1
      end

    end

    p

  end

  def value(field_type)

    result = field_values.select { |fv| fv.name == field_type.name }

    if field_type.array
      result
    else
      result[0] if result.length >= 1
    end

  end

  def field_type(name, role = nil)
    fts = parent_type.field_types.select { |ft| ft.name == name && ft.role == role }
    fts[0] unless fts.empty?
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
