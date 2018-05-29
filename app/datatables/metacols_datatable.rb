# frozen_string_literal: true

class MetacolsDatatable < Datatable

  private

  def data

    rows.map do |m|
      args = m.arguments.to_json
      args = args[0, 49] + '...' if args.length > 50
      cols = [
        "<a href='metacols/#{m.id}'>#{m.id}</a>" + (m.status == 'ERROR' ? " <span style='color:red'>(ERROR)</span>" : ''),
        m.path,
        args,
        m.user.login,
        m.created_at.to_formatted_s(:short),
        m.updated_at.to_formatted_s(:short)
      ]
      cols.push "<a href='metacols/#{m.id}/stop'><i class='icon-stop'></i></a>" if m.status == 'RUNNING'
      cols
    end
  end

  def rows
    @samples ||= fetch_rows
  end

  def fetch_rows

    metacols = Metacol.order("#{sort_column} #{sort_direction}")
    metacols = metacols.page(page).per_page(per_page) # .includes(:user)

    if params[:status] == 'RUNNING'
      prefix = "status = 'RUNNING'"
      @view.cookies[:active_metacol_search_string] = params[:sSearch]
    else
      prefix = "status != 'RUNNING'"
      @view.cookies[:stopped_metacol_search_string] = params[:sSearch]
    end

    if params[:sSearch].present?

      key = params[:sSearch]
      u = User.find_by_login(key)

      metacols = if u
                   metacols.where(prefix + ' and user_id = :uid', status: params[:status], uid: u.id.to_s)
                 else
                   metacols.where(prefix + ' and path like :search', status: params[:status], search: "%#{key}%")
                 end

    else

      metacols = metacols.where(prefix, status: params[:status])

    end

    metacols

  end

  def sort_column
    columns = %w[id path cid id created_at updated_at] # possibly redefine in children classes
    columns[params[:iSortCol_0].to_i]
  end

end
