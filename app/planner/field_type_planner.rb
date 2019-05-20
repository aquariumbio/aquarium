module FieldTypePlanner

  def can_produce(fv)

    case ftype

    when 'sample'

      if fv.child_sample

        puts "\e[93mCan '#{OperationType.find(parent_id).name}' produce #{fv.name} (#{fv.object_type ? fv.object_type.name : '?'}) for Operation #{fv.parent_id}"

        if fv.object_type

          allowable_field_types.each do |aft|
            puts "  #{aft.object_type ? aft.object_type.name : '?'} =? #{fv.object_type ? fv.object_type.name : '?'}"
            if aft.sample_type && fv.sample_type == aft.sample_type && fv.object_type == aft.object_type
              puts "... yes.\e[39m"
              return true
            end
          end

        else

          puts "  checking afts: #{allowable_field_types.length} x #{fv.field_type.allowable_field_types.length}"

          allowable_field_types.each do |aft_from|
            fv.field_type.allowable_field_types.each do |aft_to|
              puts "  #{aft_from.object_type ? aft_from.object_type.name : '?'} =? #{aft_to.object_type ? aft_to.object_type.name : '?'}"
              if aft_from.equals aft_to
                puts " ... yes.\e[39m"
                return true
              end
            end

          end

        end

        puts " ... no.\e[39m"
        false

      else # fv says its a sample, but doesn't specify a sample

        puts "\e[93m   #{fv.name}s type is sample, but doesn't specify a sample\e[39m"

        if fv.field_type.part # fv is part of an empty collection

          puts "\e[93m   #{fv.name} is part of any empty collection!\e[39m"

          allowable_field_types.each do |aft|
            if !aft.sample_type && fv.object_type == aft.object_type
              puts "\e[93m       #{name} can produce #{fv.name} \e[39m"
              return true
            end
          end

          return false

        else

          return false

        end

      end

    else # fv is not a sample

      false

    end

  end

  def random

    if allowable_field_types.empty?
      [nil, nil]
    else
      aft = allowable_field_types.sample
      if array
        if aft.sample_type
          return [aft.sample_type.samples.sample(3), aft] 
        else
          return [[nil,nil,nil], aft]
        end
      elsif !aft.sample_type
        return [nil, aft]
      elsif aft.sample_type.samples.empty?
        raise "There are no samples of type #{aft.sample_type.name}"
      else
        return [aft.sample_type.samples.sample, aft]
      end
    end

  end

  def choose_aft_for(sample)

    afts = allowable_field_types.select do |aft|
      begin
        aft.sample_type_id == sample.sample_type.id  
      rescue Exception => e
        true
      end
    end

    afts.sample unless afts.empty?

  end

end
