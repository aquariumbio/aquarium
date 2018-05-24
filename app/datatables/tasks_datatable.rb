class TasksDatatable < Datatable

  def initialize(view, status, tp)
    @status = status
    @tp = tp # task prototype id
    super(view)
  end

  private

  def status_selector(task)

    html = "<select class='status-selector' data-task-id=#{task.id}>"

    task.task_prototype.status_option_list.each do |opt|

      html += if opt == task.status
                "<option selected>#{opt}</option>"
              else
                "<option>#{opt}</option>"
              end

    end

    html += '</select>'

    html

  end

  def data

    rows.map do |task|

      [
        link_to(task.id, task),
        @tp ? task.name : "<b>#{task.task_prototype.name}:</b> #{task.name}",
        status_selector(task),
        task.budget ? task.budget.name : 'no budget specified',
        task.user ? link_to(task.user.login, task.user) : '?',
        task.created_at.to_formatted_s(:short),
        task.updated_at.to_formatted_s(:short)
      ]

    end

  end

  def rows
    @rows ||= fetch_rows
  end

  def fetch_rows

    tasks = Task.order("#{sort_column} #{sort_direction}")
    tasks = tasks.page(page).per_page(per_page)

    @view.cookies["#{@tp.name}_search"] = params[:sSearch] if @tp

    if params[:sSearch].present?

      key = params[:sSearch]
      u = User.find_by(login: key)

      tasks = if u
                tasks.where('task_prototype_id = :tpid and status = :status and user_id like :uid',
                            search: "%#{key}%",
                            uid: u.id.to_s,
                            status: @status,
                            tpid: @tp.id)
              else
                tasks.where('task_prototype_id = :tpid and status = :status and name like :search',
                            search: "%#{key}%",
                            status: @status,
                            tpid: @tp.id)
              end

    else

      if @tp
        tasks = tasks.where('task_prototype_id = :tpid and status = :status',
                            status: @status,
                            tpid: @tp.id)
      elsif params[:sample_id]
        sample = Sample.find_by(id: params[:sample_id])
        jobs = sample.items.collect(&:touches).flatten.collect(&:job)
        touches = jobs.collect(&:touches).flatten
        tasks = touches.collect(&:task).flatten.select(&:!)
        tasks = (tasks.select { |t| t.mentions? sample }).uniq
      else
        tasks = []
      end
    end

    tasks

  end

  def sort_column
    columns = %w[id name id created_at updated_at] # possibly redefine in children classes
    columns[params[:iSortCol_0].to_i]
  end

end
