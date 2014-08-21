class LogsDatatable < Datatable

  private  

  def data

    rows.map do |job|

      args = job.arguments.to_json

      if args.length > 50
        args = args[0,49] + '...'
      end

      if job.metacol_id
        mc = " (<a href='metacols/#{job.metacol_id}'>#{job.metacol_id}</a>)"      
      else
        mc = ""
      end

      [
        link_to(job.id, job),
        job.path ? job.path.split('/').last : "?",
        "<span class='showhide'>#{args}</span>",
        job.submitter + mc,
        job.doer,
        job.created_at.to_formatted_s(:short),
        job.updated_at.to_formatted_s(:short) 
      ]

    end

  end

  def rows
    @rows ||= fetch_rows
  end

  def fetch_rows

    jobs = Job.order("#{sort_column} #{sort_direction}")
    jobs = jobs.page(page).per_page(per_page)

    if params[:sSearch].present?

      key = params[:sSearch]
      u = User.find_by_login(key)

      if u
        jobs = jobs.where("pc = -2 and ( user_id like :uid or submitted_by like :sid )", search: "%#{key}%", uid: u.id.to_s, sid: u.id)
      elsif /m[0-9]+/ =~ key
        jobs = jobs.where("pc = -2 and metacol_id = :mic", mic: key[1,10].to_i )
      else
        jobs = jobs.where("pc = -2 and path like :search", search: "%#{key}%")
      end

    else
      jobs = jobs.where("pc = -2")
    end

    jobs

  end

  def sort_column
    columns = %w[id path id id id created_at updated_at] # possibly redefine in children classes
    columns[params[:iSortCol_0].to_i]
  end

end

