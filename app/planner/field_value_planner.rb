module FieldValuePlanner

  def satisfied_by_environment

    puts "Checking whether input #{name} needs to be made"

    case val
    when Sample
      items = val.items.select { |i| !i.deleted? }
      if items.length > 0
        puts "    #{items.length} items found for #{val.sample_type.name} #{val.id}"
        true
      else
        puts "    No items found for #{val.sample_type.name} #{val.id}"
        false
      end
    else
      false
    end

  end

end