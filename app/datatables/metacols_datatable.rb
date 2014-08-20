class MetacolsDatatable < Datatable

  private  

  def data
    rows.map do |m|
      args = m.arguments.to_json
      if args.length > 50
        args = args[0,49] + '...'
      end
      cols = [
        "<a href='metacols/#{m.id}'>#{m.id}</a>" + (m.status == "ERROR" ? " <span style='color:red'>(ERROR)</span>" : ""),
        m.path,
        args,
        m.user.login
      ]
      if m.status == 'RUNNING'
        cols.push "<a href='metacols/#{m.id}/stop'><i class='icon-stop'></i></a>"
      end
      cols
    end
  end

  def rows
    @samples ||= fetch_rows
  end

  def fetch_rows

    metacols = Metacol.order("#{sort_column} #{sort_direction}")
    metacols = metacols.page(page).per_page(per_page) # .includes(:user)

    if params[:status] == "RUNNING"
      prefix = "status = 'RUNNING'"
    else
      prefix = "status != 'RUNNING'"
    end

    if params[:sSearch].present?

      key = params[:sSearch]
      u = User.find_by_login(key)

      if u
        metacols = metacols.where(prefix + " and user_id = :uid", status: params[:status], uid: u.id.to_s )
      else 
        metacols = metacols.where(prefix + " and path like :search", status: params[:status], search: "%#{key}%" )
      end

    else

      metacols = metacols.where(prefix, status: params[:status] )
        
    end

    metacols

  end

end

