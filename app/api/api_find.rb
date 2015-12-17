module ApiFind

  def pluralize_table_names spec

    newspec = spec.clone

    reps =  { object_type: :object_types,
              sample: :samples,
              sample_type: :sample_types,
              task_prototype: :task_prototypes,
              job: :jobs,
              upload: :uploads
    }

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
               "task_prototype" => TaskPrototype, "touch" => Touch,
               "task_prototype" => TaskPrototype,
               "workflow"=>Workflow,
               "workflow_thread"=>WorkflowThread,
               "upload"=>Upload }

    query = models[args[:model]]

    if(query)
      query = query.includes(args[:includes]) if args[:includes]
      query = query.limit(args[:limit]) if args[:limit]
      if args[:where]
        query = query.where(pluralize_table_names(args[:where]))
      else
        query = query.all
      end
      add query.collect { |r| r.export }
      #For requests that don't map to a model
    elsif args[:model]=='workflow_form'
      workflow=Workflow.find(args[:where][:id])
      if workflow
        add [Workflow.find(args[:where][:id]).form]
      end
    elsif args[:model]=='file'
      if args[:where][:id]
        upload=Upload.find(args[:where][:id])
        if upload
          add read_file_content upload.path
        end
      elsif args[:where][:job]
        uploads=Upload.joins(:job).where(pluralize_table_names(args[:where]))
        if uploads
          if uploads.size>1
            file_contents=Hash.new
            uploads.each { |upload|
              file_name=upload.upload_file_name
              file_content=read_file_content upload.path
              file_contents[file_name]=file_content}
            add [file_contents]
          else
            upload= uploads.first
            file_name=upload.upload_file_name
            file_contents= read_file_content upload.path
            add [{file_name =>file_contents}]
          end
        end
      end
    elsif args[:model]=='url_for_upload'
      upload = Upload.find(args[:where][:id])
      if upload
        add [upload.url]
      end
    end
    #if args[:model] == "job"
    #  query = query.select { |j| j.krill? }
    #end
  end

  def read_file_content file_path
    file = File.open(file_path, "r")
    file.readlines
  end

end
