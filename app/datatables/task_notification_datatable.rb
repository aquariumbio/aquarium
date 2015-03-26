class TaskNotificationDatatable < Datatable

  def initialize(view) 
    @view = view
    super(view)
  end

  private  

  def data

    rows.map do |note|

      [
        note.content,
        note.job_id,
        "-",
        note.created_at.to_formatted_s(:short),
        "<input type='checkbox' class='read' data-note-id=#{note.id} #{note.read ? 'checked' : ''}></input>"
      ]

    end

  end 

  def rows
    @rows ||= fetch_rows
  end

  def fetch_rows

    task = Task.find(@view.params[:task_id])
   
    if @view.params[:include_unread] == "true"
      @view.logger.info "including unread: #{@view.params.to_json}"
      task.notifications
    else
      @view.logger.info "not including unread: #{@view.params.to_json}"      
      task.notifications.reject { |n| n.read }
    end

  end

  def sort_column
    columns = %w[content job_id job_id created_at read] # possibly redefine in children classes
    columns[params[:iSortCol_0].to_i]
  end

end

