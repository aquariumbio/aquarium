class SamplesDatatable < Datatable

  private

  def limit s
    if s && s.length > 20
      s[0, 20] + '...'
    else
      s
    end
  end

  def data

    rows.map do |s|

      basics = [
        link_to(s.id, s),
        s.name,
        s.project,
        limit(s.description),
        s.owner
      ]

      fields = s.displayable_properties

      links = [
        link_to(Rails.application.routes.url_helpers.edit_sample_path(s)) do
          "<i class='icon-pencil'></i>".html_safe
        end,
        link_to(s, method: :delete, data: {
                  confirm: 'Are you sure you want to delete this sample definition? Note, deleting will fail if there are an items associated with this sample.'
                }) do
          "<i class='icon-remove'></i>".html_safe
        end
      ]

      basics + fields + links

    end
  end

  def rows
    @samples ||= fetch_rows
  end

  def fetch_rows

    samples = Sample.order("#{sort_column} #{sort_direction}")
    samples = samples.page(page).per_page(per_page)

    sample_type = SampleType.find(params[:sample_type_id])

    @cookie_name = "sample_search_string_#{sample_type.name}".to_sym
    @view.cookies[@cookie_name] = params[:sSearch]

    if params[:sSearch].present?
      key = params[:sSearch]
      u = User.find_by_login(key)
      if u
        samples = samples.where("sample_type_id = :stid and user_id like :uid", stid: params[:sample_type_id], uid: u.id)
      elsif key.to_i != 0
        samples = samples.where("sample_type_id = :stid and id like :search", stid: params[:sample_type_id], search: key.to_i)
      else
        samples = samples.where("sample_type_id = :stid and ( name like :search or project like :search )", stid: params[:sample_type_id], search: "%#{key}%")
      end
    else
      samples = samples.where("sample_type_id = :stid", stid: params[:sample_type_id])
    end

    samples

  end

  def sort_column
    columns = %w[id name project description user_id field1 field2 field3 field4 field5 field6 field7 field8] # possibly redefine in children classes
    columns[params[:iSortCol_0].to_i]
  end

end
