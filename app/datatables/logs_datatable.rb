class LogsDatatable

  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: jobs.count,
      iTotalDisplayRecords: jobs.total_entries,
      aaData: data
    }
  end

private  

  def data
    jobs.map do |job|
      [
        link_to(job.id, job),
        job.path,
        job.submitter,
        job.doer,
        job.created_at.to_formatted_s(:short),
        job.updated_at.to_formatted_s(:short) 
      ]
    end
  end

  def jobs
    @jobs ||= fetch_jobs
  end

  def fetch_jobs

    jobs = Job.order("#{sort_column} #{sort_direction}")
    jobs = jobs.page(page).per_page(per_page)

    if params[:sSearch].present?
      key = params[:sSearch]
      u = User.find_by_login(key)
      if u
        jobs = jobs.where("user_id like :uid or submitted_by like :sid", search: "%#{key}%", uid: u.id.to_s, sid: u.id)
      else
        jobs = jobs.where("path like :search", search: "%#{key}%")
      end
    end

    jobs

  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[id path created_at updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

