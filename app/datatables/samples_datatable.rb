class SamplesDatatable

  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: samples.count,
      iTotalDisplayRecords: samples.total_entries,
      aaData: data
    }
  end

private  

  def data
    samples.map do |s|
      basics = [
        link_to(s.id, s),
        s.name,
        s.project,
        s.description,
        s.owner
      ]
      fields = s.displayable_properties
      links = [1,2,3]
      basics + fields + links
    end
  end

  def samples
    @samples ||= fetch_samples
  end

  def fetch_samples

    samples = Sample.order("#{sort_column} #{sort_direction}")
    samples = samples.page(page).per_page(per_page)

    if params[:sSearch].present?
      key = params[:sSearch]
      u = User.find_by_login(key)
      if u
        samples = samples.where("sample_type_id = :stid and user_id like :uid", stid: params[:sample_type_id], uid: u.id)
      else 
        samples = samples.where("sample_type_id = :stid and ( name like :search or project like :search )", stid: params[:sample_type_id], search: "%#{key}%")
      end
    else
        samples = samples.where("sample_type_id = :stid", stid: params[:sample_type_id] )
    end

    samples

  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[id name created_at updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

