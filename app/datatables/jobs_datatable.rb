class JobsDatatable < Datatable

  private  

  def window t1, t2, pc

    now = Time.now

    if pc >= 0 # running
      msg = "<span style='color: green'>running</span>"
    elsif t1 > now # future
      msg = "Start between " + @view.time_ago_in_words(t1) + " and " + @view.time_ago_in_words(t2) + " from now"
    elsif t1 < now && now < t2 # current
      msg = "Start within " + @view.time_ago_in_words(t2)
    else # past due!
      msg = "<span style='color: red'>" + @view.distance_of_time_in_words(now-t2) + " past due</span>"
    end

    msg.gsub(/about/,"")

  end

  def data

    rows.map do |j|

      sub = User.find(j.submitted_by)
      doer = User.find_by_id(j.user_id)
      group = Group.find(j.group_id)
      name = j.path.split('/').last.split('.').first 

      stop = link_to(
          '/interpreter/cancel?job=' + j.id.to_s, 
          data: { confirm: "Are you sure you want to cancel job #{j.id}, protocol '#{name}'?" },
          class: "stop" ) do 
        "<i class='icon-remove'></i>".html_safe 
      end

      [ 
        link_to(j.id,j,class: "jobs-jid"), 
        "<b>" + name + "</b>",
        link_to(sub.login, sub),
        doer ? link_to(doer.login,doer) : "-",
        link_to(group.name,group),
        window(j.desired_start_time,j.latest_start_time,j.pc),
        j.updated_at.to_formatted_s(:short),
        j.start_link("<i class='icon-play'></i>"),
        stop
      ]
    end

  end

  def rows
    @rows ||= fetch_rows
  end

  def fetch_rows

    now = Time.now
 
    jobs = case params[:type]
      when "table-pending"
        Job.where("pc = -1 AND (latest_start_time < ? OR ( desired_start_time < ? AND ? <= latest_start_time) )", now, now, now )
      when "table-future"
        Job.where("pc = -1 AND ? <= desired_start_time", now)
      when "table-active"
        Job.where("pc >= 0")
      else
        mid = params[:type].split('-').last.to_i
        Job.where("pc != -2 AND metacol_id = ?", mid)
    end

    # unless /metacol/ =~ params[:type]
      if params[:filter] == "user-radio"
        uid = params[:user_id].to_i
        jobs = jobs.where("submitted_by = ? OR user_id = ?", uid, uid)
      elsif params[:filter] == "group-radio"
        jobs = jobs.where(group_id: params[:group_id].to_i)
      end
    # end

    jobs = jobs.page(page).per_page(per_page)
    jobs

  end

  def sort_column
    columns = %w[id]
  end

end
