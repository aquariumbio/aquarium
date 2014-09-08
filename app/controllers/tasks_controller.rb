class ProductionTask < Task
end

class ProductionTaskPrototype < TaskPrototype
end

class TasksController < ApplicationController

  # GET /tasks
  # GET /tasks.json
  def index

    @task_prototype = TaskPrototype.find(params[:task_prototype_id])

    @task_search_cookie_name = "#{@task_prototype.name}_search".to_sym
    @task_status_cookie_name = "#{@task_prototype.name}_status".to_sym
    cookies[@task_search_cookie_name] ||= current_user.login

    @status_options = @task_prototype.status_option_list

    if params[:option]
      @option = params[:option]
    elsif cookies[@task_status_cookie_name]
      @option = cookies[@task_status_cookie_name]
    else
      @option = @status_options[0]
    end

    cookies[@task_status_cookie_name] = @option
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: TasksDatatable.new(view_context,@option,@task_prototype) }
    end

  end 

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    @task = Task.find(params[:id])

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
        format.html { redirect_to  tasks_url(task_prototype_id: @task.task_prototype.id), notice: "Task #{@task.name} was successfully created." }
        format.json { render json: @task, status: :created, location: @task }
      else
        format.html { render action: "new" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update
    @task = Task.find(params[:id])
    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html { redirect_to tasks_url(task_prototype_id: @task.task_prototype.id), notice: 'Task was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
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

      TaskPrototype.all.each do |tp|
        tp.destroy
      end

      Task.all.each do |t|
        t.destroy
      end

      ProductionTaskPrototype.switch_connection_to(:production_server)
      ProductionTaskPrototype.all.each do |tp|
        new_tp = TaskPrototype.new(tp.attributes.except("created_at","updated_at"))
        new_tp.id = tp.id
        new_tp.save
      end

      ProductionTask.switch_connection_to(:production_server)
      ProductionTask.all.each do |t|
        new_task = Task.new(t.attributes.except("created_at","updated_at"))
        new_task.id = t.id
        new_task.save validate: false
      end


      redirect_to production_interface_path, notice: "#{TaskPrototype.all.length} task prototypes and #{Task.all.length} tasks copied."

    else
   
      redirect_to production_interface_path, notice: "This functionality is not available in production mode."

    end

  end

  def update_status

    t = Task.find(params[:task])
    t.status = params[:status]
    t.save

    render json: { result: 'ok' }

  end

end

