module FieldTypePlanner

  def can_produce fv

    case ftype

    when "sample"
      if fv.child_sample
        allowable_field_types.each do |aft|
          if aft.sample_type
            puts "  Operations of type '#{OperationType.find(parent_id).name}' can make input #{fv.name} for Operation #{fv.parent_id}"
            return true if fv.child_sample.sample_type == aft.sample_type
          end
        end
        return false
      else
        return false
      end

    else
      return false
    end

  end

end
