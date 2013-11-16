module Oyster

  def get_sha path

    begin
      file = Blob.get_file -1, path
    rescue Exception => e
      raise "Could not find file '#{path}' on github: " + e.to_s
    end
    
    file[:sha]

  end

  def submit sha, path, args, scheduling

    # get the blob and parse its arguments
    blob = Blob.get sha, path
    protocol = Plankton::Parser.new( path, blob.xml )
    # protocol.job_id = -1
    protocol.parse_arguments_only

    # Set up a new scope and push the arguments
    scope = Scope.new {}

    protocol.args.each do |a|
      val = args[a.name.to_sym]
      puts " ====> #{a.name} -> #{val}"
      if a.type == 'number' && val.to_i == val.to_f
        scope.set a.name.to_sym, val.to_i
      elsif a.type == 'number' && val.to_i != val.to_f
        scope.set a.name.to_sym, val.to_f
      else
        scope.set a.name.to_sym, val
      end
    end

    scope.push

    # create a new job
    job = Job.new
    job.sha = sha
    job.path = path
    job.desired_start_time = scheduling[:desired]
    job.latest_start_time = scheduling[:latest]
    job.group_id = Group.find_by_name(scheduling[:group]).id
    job.user_id = 1
    job.pc = Job.NOT_STARTED
    job.state = { stack: scope.stack }.to_json
    job.save

    job.id

  end

end

