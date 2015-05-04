module ApiDrop

  def drop args

    case args[:model]

    when "sample"
      drop_aux Sample, args

    when "task"
      drop_aux Task, args

    end

  end

  def drop_aux model, args
    if args[:names]
      args[:names].each do |name|
        m = model.find_by_name name
        if model.okay_to_drop? m, @user
          m.destroy
        end
      end
    end

    if args[:ids]
      args[:ids].each do |id|
        m = model.find_by_id id
        if model.okay_to_drop? m, @user
          m.destroy
        end
      end
    end      
  end

end
