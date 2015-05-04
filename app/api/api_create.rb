module ApiCreate

  def create args

    case args[:model]

    when "sample"
      create_sample args

    when "task"
      create_task args

    when "job"
      create_job args

    else
      warn "Creating at #{args[:model]} not implemented"

    end

  end

  def create_task args
  
    num_tasks = Task.where("created_at > ? AND user_id = ?", 1.day.ago, @user.id).count
    max = Bioturk::Application.config.task_creation_limit
    return error "Limit of #{max} new tasks in 24 hours reached." if num_tasks > max

    puts "@user_id = #{@user.id}"

    t = Task.new({
      name: args[:name], 
      status: args[:status], 
      task_prototype_id: args[:task_prototype_id],
      specification: args[:specification].to_json,
      user_id: @user.id})

    puts "t.user_id = #{t.user_id}"

    if t.save
      add [ t ]
    else
      error "Could not create task: " + t.errors.full_messages.join(', ')
    end

  end

  def create_job args
    return error "Create job not yet implemented"
  end

  def create_sample args

    st = SampleType.find_by_name(args[:type])
    return error "Could not find sample type #{args[:type]}" unless st

    num_samples = Sample.where("created_at > ? AND user_id = ?", 1.day.ago, @user.id).count
    max = Bioturk::Application.config.sample_creation_limit
    return error "Limit of #{max} new samples in 24 hours reached." if num_samples > max

    s = Sample.new({
      name: args[:name], 
      sample_type_id: st.id, 
      description: args[:description],
      user_id: @user.id,
      project: args[:project]
    })

    if args[:fields]
      args[:fields].each do |name,val|
        s.set_property name.to_s, val
      end
    end

    if s.save
      add [ s ]
    else
      error "Could not create Sample: " + s.errors.full_messages.join(', ')        
    end

  end

end

