module FieldValuer

  def destroy_fields
    field_values.destroy_all
  end

  def field_values
    FieldValue.includes(:child_sample).where(parent_class: self.class.to_s, parent_id: self.id)
  end

  def set_property_aux ft, fv, val

    # puts "SETTING #{fv.name}(#{fv.role}) to #{val.inspect}"

    case ft.ftype 

    when 'string', 'url'
      self.errors.add(:set_property,"#{val} is not a string") unless val.class == String
      fv.value = val

    when 'number'
      self.errors.add(:set_property,"#{val} is not a number") unless val.respond_to? :to_f
      fv.value = val.to_s
  
    when 'sample'
      self.errors.add(:set_property,"#{val} is not a sample") unless val.class == Sample
      fv.child_sample_id = val.id

    when 'item'
      self.errors.add(:set_property,"#{val} is not a item") unless val.class == Item
      fv.child_item_id = val.id

    end

    fv

  end

  def set_property name, val, role=nil

    ft = field_type name, role

    unless ft
      self.errors.add(:no_such_property,"#{self.class} #{id} does not have a property named #{name}.")
      return nil
    end

    fvs = field_values.select { |fv| fv.name == name && fv.role == role }

    if ft.array && val.class == Array

      new_fvs = val.collect { |v|
        set_property_aux(ft,field_values.create(name: name,field_type_id:ft.id,role:role),v)
      }

      if self.errors.empty? 
        new_fvs.each { |fv| fv.save }
        fvs.each { |fv| fv.destroy }
      end

      return self

    elsif ft.array && val.class != Array      

      self.errors.add(:set_property,"Tried to set property #{ft.name}, an array, to something that is not an array.")
      return nil

    elsif !ft.array && val.class == Array

      self.errors.add(:set_property,"Tried to set property #{ft.name}, which is not an array, to something is an array.")
      return nil

    elsif !ft.array && val.class != Array      

      if fvs.length == 0
        fvs = [ field_values.create(name: name,field_type_id:ft.id,role:role) ]
      end

      if ft && fvs.length == 1
        fv = set_property_aux(ft,fvs[0],val)
      else 
        self.errors.add(:set_property,"Could not set #{self.class} #{id} property #{name} to #{val}")
        return nil
      end

      fv.save if self.errors.empty?
      return self

    end

  end  

  def basic_value ft, fv

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

  def properties

    p = {}

    parent_type.field_types.each do |ft|

     values = field_values.select { |fv| fv.name == ft.name }.collect { |fv| basic_value ft, fv }

     if ft.array
        p[ft.name] = values
      else
        if values.length == 1
          p[ft.name] = values[0]
        end
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

  def field_type name, role=nil
    fts = parent_type.field_types.select { |ft| ft.name == name && ft.role == role }
    if fts.length > 0
      fts[0]
    else
      nil
    end
  end

  def displayable_properties

    parent_type.field_types.collect do |ft|
      v = value ft
      if v.class == Array
        v.collect { |u| u.to_s }.join(", ")
      else
        v.to_s
      end
    end

  end  

end