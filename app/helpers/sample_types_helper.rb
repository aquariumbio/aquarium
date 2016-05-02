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

  def self.upgrade_sample s

    (1..8).each do |i|
      n = s.sample_type.fieldname i       
      t = s.sample_type.fieldtype i 
      if t == [ 'string' ] || t == [ 'url' ] || t == [ 'number' ]
        fv = s.field_values.new name: n, value: s["field#{i}"].to_s
      elsif t != [ 'not used' ]
        c = Sample.find_by_name(s["field#{i}"])
        raise "Could not find #{s["field#{i}"]} of type #{t}" unless c
        fv = s.field_values.new name: n, child_sample_id: c.id
      end
      fv.save if fv
    end

    return s

  end

end
