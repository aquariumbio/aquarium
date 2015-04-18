module ApiDrop

  def okay_to_drop? sample

    warn "Could not find sample" and return false unless sample
    warn "Not allowed to delete sample #{sample.id}" and return false unless sample.user_id == @user.id
    warn "Could not delete sample #{sample.id} becuase it has associated items" and return false unless sample.items.length == 0

    true

  end

  def drop args

    case args[:model]

    when "sample"

      if args[:names]
        args[:names].each do |name|
          s = Sample.find_by_name name
          if okay_to_drop? s
            s.destroy
          end
        end
      end

      if args[:ids]
        args[:ids].each do |id|
          s = Sample.find_by_id id
          if okay_to_drop? s
            s.destroy
          end
        end
      end      

    end

  end

end