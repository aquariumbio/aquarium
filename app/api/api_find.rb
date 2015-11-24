module ApiFind

  def pluralize_table_names spec

    newspec = spec.clone

    reps =  { object_type: :object_types,
              sample: :samples,
              sample_type: :sample_types,
              task_prototype: :task_prototypes }

    spec.each do |k,v|
      if reps.has_key? k
        newspec.delete(k)
        newspec[reps[k]] = v
      end
    end

    puts "#{spec} ==> #{newspec}"
    newspec

  end

  def find args

    models = { "item" => Item, "job" => Job, "sample" => Sample, "user" => User,
               "task" => Task, "sample_type" => SampleType, "object_type" => ObjectType,
               "task_prototype" => TaskPrototype, "touch" => Touch }

    query = models[args[:model]]
    query = query.includes(args[:includes]) if args[:includes]
    query = query.limit(args[:limit]) if args[:limit]

    if args[:where]
      query = query.where(pluralize_table_names(args[:where]))
    else
      query = query.all
    end

    #if args[:model] == "job"
    #  query = query.select { |j| j.krill? }
    #end

    add query.collect { |r| r.export }

  end

end
