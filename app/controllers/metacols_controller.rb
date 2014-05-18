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

    @user_id = params[:user_id] ? params[:user_id].to_i : current_user.id

    if @user_id >= 0

      @user = User.find(@user_id)
      @active_metacols = Metacol.where("status = 'RUNNING' AND user_id = ?", @user_id).order('id DESC')
      @completed_metacols = Metacol.paginate(page: params[:page], :per_page => 10).where("status != 'RUNNING' AND user_id = ?", @user_id).order('id DESC')

    else

      @active_metacols = Metacol.where("status = 'RUNNING'").order('id DESC')
      @completed_metacols = Metacol.paginate(page: params[:page], :per_page => 10).where("status != 'RUNNING'").order('id DESC')

    end

    @daemon_status = ""
    if current_user && current_user.is_admin 
      IO.popen("ps a | grep [r]unner") { |f| f.each_line { |l| @daemon_status += l } } 
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @metacols }
    end
  end

  def show

    @mc = Metacol.find(params[:id])

    @sha = @mc.sha
    @path = @mc.path

    begin
      @content = content @mc.sha, @mc.path
    rescue
      flash[:error] = "Octokit Era Problem: Could find metacol '#{@mc.path}', because the path probably has no repo information in it."
      redirect_to metacols_path
      return
    end

    @errors = ""

    begin
      @metacol = Oyster::Parser.new(@path,@content).parse(JSON.parse(@mc.state, :symbolize_names => true )[:stack].first)
    rescue Exception => e
      @errors = "ERROR: " + e.to_s
    end

    @metacol.set_state( JSON.parse @mc.state, :symbolize_names => true )

    if @errors==""
      @metacol.id = @mc.id
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
            flash[:error] = "Could not parse json for argument #{a[:name]}: " + e.to_s
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

    (@metacol.jobs.select { |j| j.pc == Job.NOT_STARTED }).each do |j|
     j.pc = Job.COMPLETED
     j.save
     log j, "CANCEL", {}
    end

    respond_to do |format|
      format.html { redirect_to metacols_path( active: true ) }
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
