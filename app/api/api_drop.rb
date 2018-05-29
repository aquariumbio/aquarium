# frozen_string_literal: true

module ApiDrop

  def drop(args)

    case args[:model]

    when 'sample'
      drop_aux Sample, args

    when 'task'
      drop_aux Task, args

    when 'workflow_thread'
      drop_aux WorkflowThread, args

    end

  end

  def drop_aux(model, args)
    if args[:names]
      args[:names].each do |name|
        m = model.find_by_name name
        m.destroy if model.okay_to_drop? m, @user
      end
    end

    if args[:ids]
      args[:ids].each do |id|
        m = model.find_by_id id
        m.destroy if model.okay_to_drop? m, @user
      end
    end
  end

end
