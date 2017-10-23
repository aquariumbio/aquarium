class StaticPagesController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user  

  def home
    @announcements = Announcement.find(:all, :order => "id desc", :limit => 5)
    respond_to do |format|
      format.html { render layout: 'aq2' }
    end    
  end

  def dismiss
    cookies[:latest_announcement] = Announcement.last.id
    redirect_to root_path
  end

  def inventory_stats
  end

  def inventory_critical
  end

  def help
  end

  def about
  end

  def template
    respond_to do |format|
      format.html { render layout: 'aq2' }
    end    
  end  

  def cost_report
    
    @report = TaskPrototype.cost_report

    respond_to do |format|
      format.html
      format.json { render json: @report }
    end    

  end 

  def protocol_usage

    @since = params[:since] ? params[:since] : 30
    jobs = Job.where("updated_at > ?", @since.days.ago )

    @protocol_summaries = {}

    jobs.each do |j| 
      @protocol_summaries[j.path] = {
        path: j.path,
        count: 1,
        latest_sha: j.sha,
        posts: PostAssociation.where(sha: j.sha).count,
        date: j.created_at
      } unless @protocol_summaries[j.path]
      @protocol_summaries[j.path][:count] += 1
      @protocol_summaries[j.path][:latest_sha] = j.sha
      @protocol_summaries[j.path][:posts] = PostAssociation.where(sha: j.sha).count    
      @protocol_summaries[j.path][:date] = j.created_at
    end

    max = 1
    @protocol_summaries.each do |k,v|
      if max < v[:count]
        max = v[:count]
      end
    end

    @protocol_summaries.each do |k,v|
      v[:percent] = v[:count].to_f / max.to_f
    end

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

  def yeast_qc

    @items = Item.includes(:sample => [ :sample_type, :user ] )
              .where("samples.sample_type_id = ?", SampleType.find_by_name("Yeast Strain").id )
              .select { |i| i.datum[:QC_result]  }

    respond_to do |format|
      format.html
      format.json { render json: @qc }
    end              

  end

  def direct_purchase

    dp = OperationType.find_by_name("Direct Purchase")

    unless dp
      flash[:error] = "No direct purchase protocol found. Contact the lab manager."
      redirect_to "/"
    end

    budgets = current_user.budgets

    unless budgets.length > 0
      flash[:error] = "No budgets for user #{current_user.name} found. Contact the lab manager."
      redirect_to "/"      
    end 

    plan = Plan.new(name: "Direct Purchase by " + current_user.name, budget_id: budgets[0].id)
    plan.save
    op = dp.operations.create status: "pending", user_id: current_user.id, x: 100, y: 100, parent_id: -1
    op.associate_plan plan
    job,operations = dp.schedule([op], current_user, Group.find_by_name(current_user.login))

    redirect_to("/krill/start?job=#{job.id}")

  end

end
