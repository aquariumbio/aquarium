class MetacolsController < ApplicationController

  before_filter :signed_in_user

  def content sha, path

    if /local_file/ =~ sha
      blob = Blob.get sha, path
      content = blob.xml.force_encoding('UTF-8')
    else
      content = Repo::contents path, sha
    end

    return content

  end

  def index

    cookies[:active_metacol_search_string] ||= current_user.login
    cookies[:stopped_metacol_search_string] ||= current_user.login

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: MetacolsDatatable.new(view_context) }
    end

  end

  def show

    @mc = Metacol.includes(:jobs).find(params[:id])

    @sha = @mc.sha
    @path = @mc.path

    begin
      @content = content @mc.sha, @mc.path
    rescue
      flash[:error] = "Octokit Era Problem: Could not find metacol '#{@mc.path}' details, because the path probably has no repo information in it."
      @content = nil
    end

    @errors = ""

    if @content

      begin
        @metacol = Oyster::Parser.new(@path,@content).parse(JSON.parse(@mc.state, :symbolize_names => true )[:stack].first)
      rescue Exception => e
        @errors = "ERROR: " + e.to_s
      end

      begin
        @metacol.set_state( JSON.parse @mc.state, :symbolize_names => true )
      rescue
        puts "Could not set metacol state"
      end

      if @errors==""
        @metacol.id = @mc.id
      end

    else

      @metacol = nil

    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @metacol }
    end

  end

  def parse_args sha, path

    logger.info "parse_args. sha = #{sha} and path = #{path}"

    @sha = sha
    @path = path
    @parse_errors = ""
    @errors = ""

    if /local_file/ =~ @sha
      blob = Blob.get @sha, @path
      @content = blob.xml.force_encoding('UTF-8')
    else
      @content = Repo::contents @path, @sha
    end

    begin
      @arguments = Oyster::Parser.new(@path,@content).parse_arguments_only
    rescue Exception => e
      @errors = e
    end

  end

  def arguments

    parse_args params[:sha], params[:path]

    respond_to do |format|
      format.html # arguments.html.erb
      format.json { render json: @metacol }
    end

  end

  def launch

    @sha = params[:sha]
    @path = params[:path]
    @info = JSON.parse(params[:info],:symbolize_names => true)

    if /local_file/ =~ @sha
      blob = Blob.get @sha, @path
      @content = blob.xml.force_encoding('UTF-8')
    else
      @content = Repo::contents @path, @sha
    end

    @arguments = Oyster::Parser.new(params[:path],@content).parse_arguments_only

    logger.info "arguments from parse_arguments_only = #{@arguments}"

    group = Group.find_by_name(@info[:group])
    
    group.memberships.each do |m|

      user = m.user
      args = {}

      @arguments.each do |a|
        
        ident = a[:name].to_sym
        val = @info[:args][ident]

        logger.info "Processing arg = #{ident}, #{val}"

        if a[:type] == 'number' && val.to_i == val.to_f
          args[ident] = val.to_i
        elsif a[:type] == 'number' && val.to_i != val.to_f
          args[ident] = val.to_f
        elsif a[:type] == 'generic'
          begin
            args[ident] = JSON.parse(val,:symbolize_keys=>true)
          rescue Exception => e
            flash[:error] = "Could not parse json (#{args[val]}) for argument #{a[:name]}: " + e.to_s
            return redirect_to arguments_new_metacol_path(sha: params[:sha], path: params[:path]) 
          end
        else
          args[ident] = val
        end

      end

      args[:aquarium_user] = user.login

      begin
        @metacol = Oyster::Parser.new(params[:path],@content).parse args
      rescue Exception => e
        flash[:error] = "Could not start metacol due to parse error. #{e.to_s}"
        return redirect_to arguments_new_metacol_path(sha: params[:sha], path: params[:path]) 
      end

      @metacol.who = current_user.id

      # Save in db
      mc = Metacol.new
      mc.path = params[:path]
      mc.sha = params[:sha]
      mc.user_id = user.id
      mc.status = 'STARTING'
      mc.state = @metacol.state.to_json

      mc.save # save to get an id

      @metacol.id = mc.id

      error = nil
      begin
        @metacol.start
      rescue Exception => e
        error = e
      end

      if !error
        mc.state = @metacol.state.to_json
        mc.status = 'RUNNING'
      else
        mc.message = "On start: " + e.message.split('[')[0]
        mc.status = 'ERROR'
      end

      mc.save # save again for state info

    end

    flash[:notice] = "Starting metacol for each member in group '#{group.name}'. Go to 'Protocols/Pending Jobs' to see jobs started by this metacol."
    redirect_to metacols_path( active: true )

  end

  def log job, type, data
    log = Log.new
    log.job_id = job.id
    log.user_id = current_user.id
    log.entry_type = type
    log.data = data.to_json
    log.save
  end

  def stop

    @metacol = Metacol.find(params[:metacol_id])
    @metacol.status = "DONE"
    @metacol.save

    n = 0
    (@metacol.jobs.select { |j| j.pc == Job.NOT_STARTED }).each do |j|
      j.pc = Job.COMPLETED
      j.user_id = j.user_id || current_user.id
      j.save
      log j, "CANCEL", {}
      n += 1
    end

    flash[:success] = "Metacol #{@metacol.id} and #{n} associated job(s) was (were) canceled."

    respond_to do |format|
      format.html { redirect_to jobs_path }
      format.json { head :no_content }
    end
    
  end

  def destroy

    Metacol.find(params[:id]).destroy
    redirect_to metacols_url(active: 'true')

  end

  def draw

    render 'draw'

  end

  def viewer
  end

end
