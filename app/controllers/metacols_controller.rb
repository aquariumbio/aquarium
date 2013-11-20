class MetacolsController < ApplicationController

  def index
    @metacols = Metacol.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @metacols }
    end
  end

  def show

    @mc = Metacol.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @metacol }
    end

  end

  def parse

    @sha = params[:sha]
    @path = params[:path]

    @blob = Blob.get @sha, @path
    @content = @blob.xml
    @errors = ""

    begin
      @metacol = Oyster::Parser.new(@content).parse
    rescue Exception => e
      @errors = e
    end

  end

  def arguments

    parse

    respond_to do |format|
      format.html # arguments.html.erb
      format.json { render json: @metacol }
    end

  end

  def launch

    parse

    args = {}
    @metacol.arguments.each do |a|
      if a[:type] == 'string' || a[:type] == 'objecttype'
        args[a[:name].to_sym] = params[a[:name].to_sym]
      else
        args[a[:name].to_sym] = params[a[:name].to_sym].to_i
      end
    end

    @metacol.start args

    # Save in db
    @mc = Metacol.new
    @mc.path = params[:path]
    @mc.sha = params[:sha]
    @mc.user_id = current_user.id
    @mc.status = 'RUNNING'
    @mc.state = @metacol.state.to_json
    @mc.save
  
    redirect_to @mc

  end

  def stop

    @metacol = Metacol.find(params[:id])

    respond_to do |format|
      format.html { redirect_to metacols_url }
      format.json { head :no_content }
    end
  end

end
