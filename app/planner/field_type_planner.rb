module FieldTypePlanner

  def can_produce fv

    case ftype

    when "sample"
      if fv.child_sample
        allowable_field_types.each do |aft|
          if aft.sample_type && fv.sample_type == aft.sample_type && fv.object_type == aft.object_type
            print "'#{OperationType.find(parent_id).name}' "
            puts  "can make sample #{fv.child_sample.id}: #{fv.child_sample.name} for Operation #{fv.parent_id}"
            return true
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
