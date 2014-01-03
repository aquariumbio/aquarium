class MetacolsController < ApplicationController

  before_filter :signed_in_user

  def index

    @active_metacols = Metacol.where("status = 'RUNNING'").order('id DESC')
    @completed_metacols = Metacol.paginate(page: params[:page], :per_page => 10).where("status != 'RUNNING'").order('id DESC')

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

    info = JSON.parse(params[:info],:symbolize_names => true)
    args = info[:args]
    group = Group.find_by_name(info[:group])
    flash[:notice] = "Starting metacol for each member in group '#{group.name}'"

    group.memberships.each do |m|

      user = m.user
      args[:aquarium_user] = user.login

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
        @metacol.start args
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

end
