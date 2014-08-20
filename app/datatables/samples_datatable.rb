class SamplesDatatable < Datatable

  private  

  def data
    rows.map do |s|
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

  def rows
    @samples ||= fetch_rows
  end

  def fetch_rows

    samples = Sample.order("#{sort_column} #{sort_direction}")
    samples = samples.page(page).per_page(per_page)

    if params[:sSearch].present?
      key = params[:sSearch]
      u = User.find_by_login(key)
      if u
        samples = samples.where("sample_type_id = :stid and user_id like :uid", stid: params[:sample_type_id], uid: u.id)
      elsif key.to_i != 0
        samples = samples.where("sample_type_id = :stid and id like :search", stid: params[:sample_type_id], search: key.to_i )
      else 
        samples = samples.where("sample_type_id = :stid and ( name like :search or project like :search )", stid: params[:sample_type_id], search: "%#{key}%")
      end
    else
        samples = samples.where("sample_type_id = :stid", stid: params[:sample_type_id] )
    end

    samples

  end

end

