module FieldTypePlanner

  def can_produce fv

    case ftype

    when "sample"

      if fv.child_sample

        puts "\e[93m   #{fv.name}'s type is sample, and it specifies sample #{fv.child_sample.name}\e[39m"

        allowable_field_types.each do |aft|
          if aft.sample_type && fv.sample_type == aft.sample_type && fv.object_type == aft.object_type
            return true
          end
        end

        return false

      else # fv says its a sample, but doesn't specify a sample

        puts "\e[93m   #{fv.name}s type is sample, but doesn't specify a sample\e[39m"

        if fv.field_type.part # fv is part of an empty collection

          puts "\e[93m   #{fv.name} is part of any empty collection!\e[39m"

          allowable_field_types.each do |aft|
            if !aft.sample_type && fv.object_type == aft.object_type
              puts "\e[93m       #{self.name} can produce #{fv.name} \e[39m"
              return true
            end
          end

          return false

        else

          return false

        end

      end

    else # fv is not a sample

      return false

    end

  end

  def random
    return nil unless allowable_sample_types.sample
    if array
      allowable_sample_types.sample.samples.sample(3) # Ahhh! So awesome.      
    else
      allowable_sample_types.sample.samples.sample    # Ahhh! So awesome.
    end
  end

end
