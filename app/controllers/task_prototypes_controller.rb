class TaskPrototypesController < ApplicationController
  # GET /task_prototypes
  # GET /task_prototypes.json
  def index
    @task_prototypes = TaskPrototype.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @task_prototypes }
    end
  end

  # GET /task_prototypes/1
  # GET /task_prototypes/1.json
  def show
    @task_prototype = TaskPrototype.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task_prototype }
    end
  end

  # GET /task_prototypes/new
  # GET /task_prototypes/new.json
  def new
    @task_prototype = TaskPrototype.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @task_prototype }
    end
  end

  # GET /task_prototypes/1/edit
  def edit
    @task_prototype = TaskPrototype.find(params[:id])
  end

  # POST /task_prototypes
  # POST /task_prototypes.json
  def create
    @task_prototype = TaskPrototype.new(params[:task_prototype])

    respond_to do |format|
      if @task_prototype.save
        format.html { redirect_to @task_prototype, notice: 'Task prototype was successfully created.' }
        format.json { render json: @task_prototype, status: :created, location: @task_prototype }
      else
        format.html { render action: "new" }
        format.json { render json: @task_prototype.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /task_prototypes/1
  # PUT /task_prototypes/1.json
  def update
    @task_prototype = TaskPrototype.find(params[:id])

    respond_to do |format|
      if @task_prototype.update_attributes(params[:task_prototype])
        format.html { redirect_to @task_prototype, notice: 'Task prototype was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task_prototype.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /task_prototypes/1
  # DELETE /task_prototypes/1.json
  def destroy
    @task_prototype = TaskPrototype.find(params[:id])
    @task_prototype.destroy

    respond_to do |format|
      format.html { redirect_to task_prototypes_url }
      format.json { head :no_content }
    end
  end
end
