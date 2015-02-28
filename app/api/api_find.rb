class Jobb < Job

  def attributes
    a = super
    a["backtrace"] = a["state"]
    a.delete "state"
    a
  end

end

class Userr < User

  def attributes
    a = super
    a.delete "password_digest"
    a.delete "remember_token"
    a.delete "key"
    a
  end

end

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

    models = { "item" => Item, "job" => Jobb, "sample" => Sample, "user" => Userr, 
               "task" => Task, "sampletype" => SampleType, "objecttype" => ObjectType }

    query = models[args[:model]]  
    query = query.includes(args[:includes]) if args[:includes]
    query = query.limit(args[:limit]) if args[:limit]

    if args[:where]
      query = query.where(pluralize_table_names(args[:where]))
    else
      query = query.all
    end

    add query

  end

end