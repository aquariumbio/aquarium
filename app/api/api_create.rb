module ApiCreate

  def create args

    case args[:model]

    when "sample"
      create_sample args

    when "task"
      create_task args

    when "job"
      create_job args

    when "workflow_thread"
      create_workflow_thread args

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
                   user_id: @user.id
                 })

    puts "t.user_id = #{t.user_id}"

    if t.save
      add [t]
    else
      error "Could not create task: " + t.errors.full_messages.join(', ')
    end

  end

  def create_job _args
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
      args[:fields].each do |name, val|
        s.set_property name.to_s, val
      end
    end

    if s.save
      add [s]
    else
      error "Could not create Sample: " + s.errors.full_messages.join(', ')
    end

  end

  def create_workflow_thread args
    # First check if the workflow specified is correct
    wf = Workflow.find(args[:workflow_id])
    return error "Workflow ID not found" unless wf

    threads = args[:thread]
    # Then for each thread,check two things
    wf_form = wf.form
    # First check if all the inputs are specified
    expected_inputs = wf_form[:inputs].collect { |input_hash| input_hash[:name] }
    threads.each { |thread|
      submitted_inputs = thread.keys
      expected_inputs.each { |expected_input|
        raise "An input:\"#{expected_input}\" is missing the threads array" unless submitted_inputs.include?(expected_input)
      }
    }

    # Then check if each input specified is correct: if the sample is a valid sample and if the sample_id of the sample is valid in this case
    wf_form[:inputs].each { |wf_form_input|
      if wf_form_input[:alternatives]
        if wf_form_input[:alternatives][0][:sample_type]
          wf_form_sample_type_id = wf_form_input[:alternatives][0][:sample_type].split(':')[0]
          threads.each { |ip_thread|
            ip_thread_sample_id = thread[ip_thread[:name]].split(':')[0]

            # Checking if the specified sample is valid
            ip_sample = Sample.find(ip_thread_sample_id)
            raise "The specified sample:#{ip_thread[:name]} is incorrect" unless ip_sample

            # Checking if the sample_type_id is correct(matches the required sample_type_id)
            input_sample_type_id = ip_sample.sample_type_id
            raise "The sample type of the sample:/'#{input[:name]}/' does not match the required sample type for this input" unless input_sample_type_id == wf_form_sample_type_id
          }
        end
      end
    }

    thread_ids = threads.collect { |thread|
      spec = wf.make_spec_from_hash(thread)
      thread = WorkflowThread.create(spec, args[:workflow_id])
      thread.id
    }
    add [{ 'thread_ids' => thread_ids }]
  end

end
