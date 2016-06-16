module FieldTyper

  def destroy_fields
    field_types.destroy_all
  end

  def field_types
    FieldType.includes(allowable_field_types: :sample_type).where(parent_class: self.class.to_s, parent_id: self.id)
  end

  def type name
    self.field_types.find { |ft| ft.name == name }
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

end