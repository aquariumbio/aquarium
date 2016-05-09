module SampleTypesHelper

  def self.upgrade st

    (1..8).each do |i|

      if st.fieldname(i) && st.fieldname(i) != "" && st.fieldtype(i).length > 0

        puts "#{i}. Upgrading #{st.fieldname(i)}:"
        puts "  Type: #{st.fieldtype(i)}"

        case st.fieldtype(i)
        when [ "number" ], [ "string" ], [ "url" ]
          ft = st.field_types.create name: st.fieldname(i), ftype: st.fieldtype(i)[0], required: true
          ft.save
        else
          ft = st.field_types.create name: st.fieldname(i), ftype: "sample", required: true
          ft.save        
          st.fieldtype(i).each do |sample_type_name|
            aft = ft.allowable_field_types.create sample_type_id: SampleType.find_by_name(sample_type_name).id
            aft.save          
          end
        end
          
      end

    end

  end

  def self.upgrade_all

    SampleType.all.each do |st|
      self.upgrade st
    end

  end

  def self.reset_upgrade
    FieldType.destroy_all
  end

end
