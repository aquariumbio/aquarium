class WizardsController < ApplicationController
  # GET /wizards
  # GET /wizards.json
  def index
    @wizards = Wizard.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @wizards }
    end
  end

  # GET /wizards/1
  # GET /wizards/1.json
  def show
    @wizard = Wizard.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @wizard }
    end
  end

  # GET /wizards/new
  # GET /wizards/new.json
  def new
    @wizard = Wizard.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @wizard }
    end
  end

  # GET /wizards/1/edit
  def edit
    @wizard = Wizard.find(params[:id])
  end

  # POST /wizards
  # POST /wizards.json
  def create

    @wizard = Wizard.new(
      name: params[:wizard][:name],
      description: params[:wizard][:description],
      specification: params[:wizard][:specification].to_json
    )

    respond_to do |format|
      if @wizard.save
        format.html { redirect_to @wizard, notice: 'Wizard was successfully created.' }
        format.json { render json: @wizard, status: :created, location: @wizard }
      else
        format.html { render action: "new" }
        format.json { render json: @wizard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /wizards/1
  # PUT /wizards/1.json
  def update
    
    @wizard = Wizard.find(params[:id])

    result = @wizard.update_attributes(
      name: params[:wizard][:name],
      description: params[:wizard][:description],
      specification: params[:wizard][:specification].to_json
    )

    respond_to do |format|
      if result
        format.html { redirect_to @wizard, notice: 'Wizard was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @wizard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wizards/1
  # DELETE /wizards/1.json
  def destroy
    @wizard = Wizard.find(params[:id])
    @wizard.destroy

    respond_to do |format|
      format.html { redirect_to wizards_url }
      format.json { head :no_content }
    end
  end
end
