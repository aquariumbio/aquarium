# frozen_string_literal: true

class TaskNotificationDatatable < Datatable

  def initialize(view)
    @view = view
    super(view)
  end

  private

  def data

    rows.map do |note|

      mid = if note.job && note.job.metacol
              link_to note.job.metacol.id, note.job.metacol
            else
              '-'
            end

      task = if @view.params[:user_id]
               "#{link_to note.task.id, note.task, target: '_parent'}: #{note.task.name} ( #{note.task.task_prototype.name} )"
             else
               note.task.id
             end

      [
        task,
        note.content,
        note.job ? link_to(note.job.id, note.job) : '-',
        mid,
        note.created_at.to_formatted_s(:short),
        "<input type='checkbox' class='read' data-note-id=#{note.id} #{note.read ? 'checked' : ''}></input>"
      ]

    end

  end

  def rows
    @rows ||= fetch_rows
  end

  def fetch_rows

    if @view.params[:task_id]

      tns = TaskNotification.where(task_id: @view.params[:task_id]).page(page).per_page(per_page).order('id DESC')

      if @view.params[:include_unread] == 'true'
        tns
      else
        tns.where(read: false)
      end

    else

      tns = TaskNotification.page(page).per_page(per_page).joins(:task).order('id DESC').where(tasks: { user_id: params[:user_id] })

      if @view.params[:include_unread] == 'true'
        tns
      else
        tns.where(read: false)
      end

    end

  end

  def sort_column
    columns = %w[content job_id job_id created_at read] # possibly redefine in children classes
    columns[params[:iSortCol_0].to_i]
  end

end
