class JobsDatatable < Datatable

  private

  def window(t1, t2, pc)

    now = Time.now

    sp = "<span title='Desired: #{t1}. Latest: #{t2}' "

    msg = if pc >= 0 # running
            sp + "style='color: green'>running</span>"
          elsif now < t1 # future
            sp + '>Start between ' + @view.time_ago_in_words(t1) + ' and ' + @view.time_ago_in_words(t2) + ' from now</span>'
          elsif t1 <= now && now < t2 # current
            sp + '>Start within ' + @view.time_ago_in_words(t2) + '</span>'
          else # past due!
            sp + "style='color: red'>" + @view.distance_of_time_in_words(now - t2) + ' past due</span>'
          end

    msg.gsub(/about/, '')

  end

  def data

    rows.map do |j|

      sub = User.find(j.submitted_by)
      doer = User.find_by_id(j.user_id)
      group = Group.find(j.group_id)
      name = j.path.split('/').last.split('.').first
      meta = j.metacol_id && !(/metacol/ =~ params[:type]) ? (' (' + link_to(j.metacol_id, j.metacol) + ')') : ''

      stop = link_to(
        '/interpreter/cancel?job=' + j.id.to_s,
        data: { confirm: "Are you sure you want to cancel job #{j.id}, protocol '#{name}'?" },
        class: 'stop'
      ) do
        "<i class='icon-remove'></i>".html_safe
      end

      [
        link_to(j.id, j, class: 'jobs-jid'),
        '<b>' + name + '</b>',
        link_to(sub.login, sub) + meta.html_safe,
        doer ? link_to(doer.login, doer) : '-',
        link_to(group.name, group),
        window(j.desired_start_time, j.latest_start_time, j.pc),
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
           when 'table-pending'
             Job.where('pc = -1 AND (latest_start_time < ? OR ( desired_start_time < ? AND ? <= latest_start_time) )', now, now, now)
           when 'table-future'
             Job.where('pc = -1 AND ? <= desired_start_time', now)
           when 'table-active'
             Job.where('pc >= 0')
           else
             mid = params[:type].split('-').last.to_i
             Job.where('pc != -2 AND metacol_id = ?', mid)
           end

    # unless /metacol/ =~ params[:type]
    if params[:filter] == 'user-radio'
      uid = params[:user_id].to_i
      jobs = jobs.where('submitted_by = ? OR user_id = ?', uid, uid)
    elsif params[:filter] == 'group-radio'
      jobs = jobs.where(group_id: params[:group_id].to_i)
    end
    # end

    jobs = jobs.page(page).per_page(10_000)
    jobs

  end

  def sort_column
    columns = %w[id]
  end

end
