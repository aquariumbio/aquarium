class TasksDatatable < Datatable

  def initialize(view,status,tp) 
    @status = status
    @tp = tp # task prototype id
    super(view)
  end

  private  

  def status_selector task

    html = "<select class='status-selector' data-task-id=#{task.id}>"

    @tp.status_option_list.each do |opt|

      puts opt

      if opt == @status
        html += "<option selected>#{opt}</option>"        
      else
        html += "<option>#{opt}</option>"
      end

    end

    html += "</select>"

    html

  end

  def data

    rows.map do |task|

      [
        link_to(task.id, task),
        task.name,
        status_selector(task),
        task.user.login,
        task.created_at.to_formatted_s(:short),
        task.updated_at.to_formatted_s(:short),
        link_to( task, method: :delete, data: { confirm: 'Are you sure?' }) do
          "<i class='icon-remove'></i>".html_safe
        end
      ]

    end

  end 

  def rows
    @rows ||= fetch_rows
  end

  def fetch_rows

    tasks = Task.order("#{sort_column} #{sort_direction}")
    tasks = tasks.page(page).per_page(per_page)

    @view.cookies["#{@tp.name}_search"] = params[:sSearch]

    if params[:sSearch].present?

      key = params[:sSearch]
      u = User.find_by_login(key)

      if u
        tasks = tasks.where("task_prototype_id = :tpid and status = :status and user_id like :uid", 
          search: "%#{key}%", 
          uid: u.id.to_s, 
          status: @status,
          tpid: @tp.id)
      else
        tasks = tasks.where("task_prototype_id = :tpid and status = :status and name like :search",
          search: "%#{key}%",
          status: @status,
          tpid: @tp.id)
      end

    else
      tasks = tasks.where("task_prototype_id = :tpid and status = :status",
        status: @status,
        tpid: @tp.id)
    end

    tasks

  end

  def sort_column
    columns = %w[id name id created_at updated_at] # possibly redefine in children classes
    columns[params[:iSortCol_0].to_i]
  end

end

