class ProductionTask < Task
end

class ProductionTaskPrototype < TaskPrototype
end

class TasksController < ApplicationController

  before_filter :signed_in_user

  # GET /tasks
  # GET /tasks.json
  def index

    if params[:task_prototype_id]

      @task_prototype = TaskPrototype.find(params[:task_prototype_id])

      @task_search_cookie_name = "#{@task_prototype.name}_search".to_sym
      @task_status_cookie_name = "#{@task_prototype.name}_status".to_sym
      cookies[@task_search_cookie_name] ||= current_user.login

      @status_options = @task_prototype.status_option_list

    else

      @status_options = []

    end

    @option = if params[:option]
                params[:option]
              elsif cookies[@task_status_cookie_name]
                cookies[@task_status_cookie_name]
              else
                @status_options[0]
              end

    cookies[@task_status_cookie_name] = @option

    begin
      sha = Repo.version(@task_prototype.metacol)
      @metacol_url = URI.encode('/metacols/new/arguments?path=' + @task_prototype.metacol + '&sha=' + sha)
    rescue Exception => e
      @metacol_url = nil
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: TasksDatatable.new(view_context, @option, @task_prototype) }
    end

  end

  def list
    render json: Task.includes(:task_prototype)
      .where(user_id: current_user.id)
      .limit(15)
      .offset(params[:offset])
      .order('id DESC')
                     .as_json(include: :task_prototype)
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show

    @task = Task.find(params[:id])

    if params[:mark_all] == 'true'
      @task.notifications.each do |n|
        n.read = true
        n.save
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task }
    end

  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new

    @task = Task.new
    @task.specification = TaskPrototype.find(params[:task_prototype_id].to_i).prototype
    @task.task_prototype_id = params[:task_prototype_id].to_i
    @task_prototype = TaskPrototype.find(params[:task_prototype_id])
    @status_options = @task_prototype.status_option_list

    @budget_info = current_user.budget_info

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @task }
    end

  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(params[:task])
    respond_to do |format|
      if @task.save
        @task.after_save_setup
        format.html { redirect_to  tasks_url(task_prototype_id: @task.task_prototype.id), notice: "Task #{@task.name} was successfully created." }
        format.json { render json: @task, status: :created, location: @task }
      else
        format.html { render action: 'new' }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update
    @task = Task.find(params[:id])
    respond_to do |format|
      if @task.update(params[:task])
        @task.after_save_setup
        format.html { redirect_to tasks_url(task_prototype_id: @task.task_prototype.id), notice: 'Task was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task = Task.find(params[:id])
    tpid = @task.task_prototype.id
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url(task_prototype_id: tpid) }
      format.json { head :no_content }
    end
  end

  def copy_tasks_from_production

    if Rails.env != 'production'

      TaskPrototype.delete_all
      Task.delete_all

      ProductionTaskPrototype.switch_connection_to(:production_server)
      tps = []
      ProductionTaskPrototype.all.each do |tp|
        new_tp = TaskPrototype.new(tp.attributes.except('created_at', 'updated_at'))
        new_tp.created_at = tp.created_at
        new_tp.updated_at = tp.updated_at
        new_tp.id = tp.id
        tps << new_tp.as_json
      end
      TaskPrototype.import!(tps)

      ProductionTask.switch_connection_to(:production_server)

      all_prod_tasks = ProductionTask.all
      Rails.logger.info "Attempting to copy #{all_prod_tasks.length} tasks"

      ts = []
      all_prod_tasks.each do |t|
        new_task = Task.new(t.attributes.except('created_at', 'updated_at'))
        new_task.created_at = t.created_at
        new_task.updated_at = t.updated_at
        new_task.id = t.id
        ts << new_task.as_json # .save validate: false
      end
      Task.import!(ts)

      redirect_to production_interface_path, notice: "#{TaskPrototype.all.length} task prototypes and #{Task.all.length} tasks copied."

    else

      redirect_to production_interface_path, notice: 'This functionality is not available in production mode.'

    end

  end

  def update_status

    t = Task.find(params[:task])
    old_status = t.status
    t.status = params[:status]
    t.save validate: false

    t.notify "#{current_user.login} changed the status from '#{old_status}' to '#{t.status}'."

    logger.info 'Errors: ' + t.errors.full_messages.join(',') unless t.errors.empty?

    render json: { result: 'ok', task: t }

  end

  def rich_id

    id = params[:id].to_i
    type = params[:type]

    st = SampleType.find_by(name: type.split('|')[0])

    if st
      s = Sample.find_by(id: id)
      if s
        render json: { sample_id: id, sample_name: s.name, type: st.name }
      else
        render json: { error: "sample #{id} not found" }
      end
    else
      i = Item.find_by(id: id)
      if !i
        render json: { error: "item #{id} not found" }
      elsif i.sample
        render json: { item_id: id, object_type: i.object_type.name, location: i.location, sample_name: i.sample.name, sample_id: i.sample.id }
      else
        render json: { item_id: id, object_type: i.object_type.name, location: i.location }
      end
    end

  end

  def notifications
    render json: TaskNotificationDatatable.new(view_context)
  end

  def read
    tn = TaskNotification.find(params[:note_id])
    tn.read = params[:unread] != 'true'
    tn.save
    render json: { result: 'ok' }
  end

  def notification_list

    if params[:mark_all] == 'true'
      tns = current_user.tasks.collect(&:notifications).flatten
      tns.each do |n|
        n.read = true
        n.save
      end
    end

    render layout: 'plugin.html.erb'

  end

  def upload

    respond_to do |format|

      format.html do
      end

      format.json do

        tasks = []
        errors = []

        ActiveRecord::Base.transaction do

          budget = Budget.find_by(name: params[:budget])

          if !budget
            errors << "Could not find budget '#{params[:budget]}'"
            raise ActiveRecord::Rollback
          else
            ubas = UserBudgetAssociation.where(user_id: current_user.id, budget_id: budget.id)
            if ubas.empty?
              errors << "User #{current_user.login} does not have permission to use budget '#{params[:budget]}'"
              raise ActiveRecord::Rollback
            elsif ubas[0].quota <= budget.spent_this_month(current_user.id)
              errors << "User #{current_user.login} has spent more than the quota (#{ubas[0].quota}) for budget '#{params[:budget]}'"
              raise ActiveRecord::Rollback
            end
          end

          params[:tasks].each do |t|

            tp = TaskPrototype.find_by(name: t[:type])

            if tp
              task = tp.tasks.create(
                name: t[:name],
                specification: t[:specification].to_json,
                user_id: current_user.id,
                budget_id: budget.id
              )
              task.status = t[:status] || tp.status_option_list.first
              task.save
              if task.errors.empty?
                tasks << task
              else
                errors += task.errors.full_messages.collect { |m| "'#{t[:name]}': #{m}" }
                raise ActiveRecord::Rollback
              end

            else

              errors << "Could not find task prototype named '#{t[:type]}'"

            end

          end

        end

        errors << 'No tasks created.' unless errors.empty?
        render json: { errors: errors, tasks: tasks.reverse.as_json(include: :task_prototype) }

      end

    end

  end

end
