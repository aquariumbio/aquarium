module FieldTyper

  def destroy_fields
    field_types.destroy_all
  end

  def field_types
    FieldType.includes(allowable_field_types: :sample_type).where(parent_class: self.class.to_s, parent_id: self.id)
  end

  def export_field_types
    fts = FieldType.includes(allowable_field_types: :sample_type).where(parent_class: self.class.to_s, parent_id: self.id)
    fts.collect do |ft|
      rft = ft.as_json
      rft[:sample_types] = ft.allowable_field_types.collect { |aft| aft.sample_type ? aft.sample_type.name : nil }
      rft[:object_types] = ft.allowable_field_types.collect { |aft| aft.object_type ? aft.object_type.name : nil }      
      rft
    end
  end

  def type name, role=nil
    self.field_types.find { |ft| ft.name == name && ( !role || ft.role == role ) }
  end

  def save_field_types raw_field_types

    if raw_field_types

      raw_field_types.each do |raw_ft|

        if raw_ft[:id]
          if raw_ft[:deleted]
            temp = FieldType.find_by_id(raw_ft[:id])
            temp.destroy if temp
          else
            ft = FieldType.find(raw_ft[:id])
            ft.update_attributes(raw_ft.slice(:name,:ftype,:required,:array,:choices))
            ft.save
          end
        else
          ft = self.field_types.create(raw_ft.except :allowable_field_types)
          ft.save
        end

        if !raw_ft[:deleted] && raw_ft[:allowable_field_types]

          raw_ft[:allowable_field_types].each do |raw_aft|
            if raw_aft[:id]
              if raw_aft[:deleted]
                AllowableFieldType.find(raw_aft[:id]).destroy
              else
                aft = AllowableFieldType.find(raw_aft[:id])
                aft.update_attributes(raw_aft.slice(:sample_type_id,:object_type_id))
              end
            else
              aft = ft.allowable_field_types.create(raw_aft.slice(:sample_type_id,:object_type_id))
              aft.save
            end
          end

        end

      end

    end

  end  

  def add_field name, sample_name, container_name, role, opts

    if !self.id
      raise "Can't add field to #{self.class} before it has been saved."
    end

    snames = sample_name.class == String ? [ sample_name ] : sample_name
    cnames = ( !container_name || container_name.class == String ) ? [ container_name ] : container_name    

    ft = field_types.create({parent_id: self.id, name: name, ftype: "sample", role: role}.merge opts)
    ft.save

    if snames
      (0..snames.length-1).each do |i|
        sample = SampleType.find_by_name(snames[i])    
        container = ObjectType.find_by_name(cnames[i])
        # raise "Could not find sample #{snames[i]}" unless sample
        # raise "Could not find container #{cnames[i]}" unless container
        ft.allowable_field_types.create(
          sample_type_id: sample ? sample.id : nil, 
          object_type_id: container ? container.id : nil
        )
      end
    end
    
    self

  end  

end