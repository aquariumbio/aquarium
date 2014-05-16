module Oyster

  def Oyster.get_sha path

    Repo::version path

  end

  def Oyster.submit h 

    group = Group.find_by_name(h[:group])
    unless group
      raise "No valid group specified when submitting '#{h[:path]}'"
    end

    # get the blob and parse its arguments
    content = Repo::contents h[:path], h[:sha]
    protocol = Plankton::Parser.new( h[:path], content )
    # protocol.job_id = -1
    protocol.parse_arguments_only

    # Set up a new scope and push the arguments
    scope = Lang::Scope.new {}

    protocol.args.each do |a|
      val = h[:args][a.name.to_sym]
      if a.type == 'number' && val.to_i == val.to_f
        scope.set a.name.to_sym, val.to_i
      elsif a.type == 'number' && val.to_i != val.to_f
        scope.set a.name.to_sym, val.to_f
      else
        scope.set a.name.to_sym, val
      end
    end

    scope.push

    sub = User.find_by_login(h[:who])

    # create a new job
    job = Job.new
    job.sha = h[:sha]
    job.path = h[:path]
    job.desired_start_time = h[:desired]
    job.latest_start_time = h[:latest]
    job.group_id = group.id
    job.submitted_by = sub ? sub.id : 0
    job.user_id = 1
    job.pc = Job.NOT_STARTED
    job.state = { stack: scope.stack }.to_json
    job.metacol_id = h[:metacol_id]
    job.save

    job.id

  end

end

