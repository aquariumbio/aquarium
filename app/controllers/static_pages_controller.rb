class StaticPagesController < ApplicationController

  before_filter :signed_in_user

  def home
  end

  def inventory_stats
  end

  def inventory_critical
  end

  def help
  end

  def about
  end

  def jobchart

    jobs = Job.where("( :newmin < created_at AND created_at < :oldmin) OR created_at > :max", 
                     { newmin: Time.at(params[:newmin].to_i),
                       oldmin: Time.at(params[:oldmin].to_i),
                       max: Time.at(params[:max].to_i) } )

    result = {}

    jobs.all.each do |j|

      start_entry = j.logs.reject { |l| l.entry_type != 'START' }
      stop_entry = j.logs.reject { |l| l.entry_type != 'STOP' }

      info = { job_id: j[:id], path: j[:path], submitted_by: User.find(j[:user_id]).login, performed_by: User.find(start_entry.first.user_id).login }

      if start_entry.length > 0 
        j[:start] = start_entry.first.created_at.to_i
      else
        j[:start] = "0"
      end

      if stop_entry.length > 0 
        j[:stop] = stop_entry.first.created_at.to_i
      else
        j[:stop] = "0"
      end

      begin
        login = User.find(j[:user_id]).login.to_sym
      rescue
        login = :unknown
      end

      unless result.has_key? login 
        result[login] = []
      end

      result[login].push( { job: j[:id], start: j[:start], stop: j[:stop], info: info } )

    end

    respond_to do |format|
      format.html
      format.json { render json: result }
    end

  end

  def analytics
    @jobs = Job.where("created_at >= :date", date: Time.now.weeks_ago(0.5))
  end

  def location
    
    if params[:name] && params[:name] != 'undefined'
      cookies.permanent[:location] = params[:name]
    elsif params[:name] && params[:name] == 'undefined'
      cookies.delete :location
    end

    if cookies[:location]
      @current_location = cookies[:location]
    else
      @current_location = 'undefined'
    end

  end

  def freezer

    @items = Item.includes(:sample)

    @result = {}

    (@items.includes(:sample).includes(:object_type).select { |i| /^[0-9a-zA-Z]*\.[0-9]*\.[0-9]*\.[0-9]*$/ =~ i.location }).each do |i|

      freezer,hotel,box,slot = i.location.split('.')
      freezer = freezer.to_sym
      hotel = hotel.to_i
      box = box.to_i
      slot = slot.to_i

      if !@result[freezer]
        @result[freezer] = Array.new(1) { Array.new(16) { Array.new(81) {nil} } }
      end

      if !@result[freezer][hotel]
        @result[freezer][hotel] = Array.new(16) { Array.new(81) {nil} }
      end

      if @result[freezer][hotel][box]
        @result[freezer][hotel][box][slot] = i
      end

    end

    respond_to do |format|
      format.html
      format.json { render json: result }
    end

  end

end
