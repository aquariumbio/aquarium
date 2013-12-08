class MetacolsController < ApplicationController

  def index
    @active_metacols = Metacol.where("status = 'RUNNING'")
    @completed_metacols = Metacol.paginate(page: params[:page], :per_page => 10).where("status != 'RUNNING'")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @metacols }
    end
  end

  def show

    @mc = Metacol.find(params[:id])
    parse @mc.sha, @mc.path

    if @errors==""
      @metacol.set_state JSON.parse(@mc.state, :symbolize_names => true )
      @metacol.id = @mc.id
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @metacol }
    end

  end

  def parse sha, path

    @blob = Blob.get sha, path
    @sha = sha
    @path = path
    @content = @blob.xml
    @errors = ""

    begin
      @metacol = Oyster::Parser.new(@content).parse
    rescue Exception => e
      @errors = e
    end

  end

  def arguments

    parse params[:sha], params[:path]

    respond_to do |format|
      format.html # arguments.html.erb
      format.json { render json: @metacol }
    end

  end

  def launch

    parse params[:sha], params[:path]

    args = {}

    @metacol.arguments.each do |a|
      if a[:type] == 'string' || a[:type] == 'objecttype'
        args[a[:name].to_sym] = params[a[:name].to_sym]
      else
        args[a[:name].to_sym] = params[a[:name].to_sym].to_i
      end
    end

    # Save in db
    @mc = Metacol.new
    @mc.path = params[:path]
    @mc.sha = params[:sha]
    @mc.user_id = current_user.id
    @mc.status = 'STARTING'
    @mc.state = @metacol.state.to_json

    @mc.save # save to get an id

    @metacol.id = @mc.id
   
    error = nil
    begin
      @metacol.start args
    rescue Exception => e
      error = e
    end

    if !error
      @mc.state = @metacol.state.to_json
      @mc.status = 'RUNNING'
    else
      @mc.message = "On start: " + e.message.split('[')[0]
      @mc.status = 'ERROR'
    end

    @mc.save # save again for state info

    redirect_to @mc

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
      format.html { redirect_to @metacol }
      format.json { head :no_content }
    end
  end

  def destroy

    Metacol.find(params[:id]).destroy

    redirect_to metacols_url

  end

end
