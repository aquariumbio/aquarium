class PrimersController < ApplicationController
  # GET /primers
  # GET /primers.json
  def index

    @user_id = params[:user_id] ? params[:user_id] : current_user.id
    @user = User.find(@user_id)

    @primers = Primer.paginate(page: params[:page], :per_page => 20).where("owner == ?", @user_id).order('id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @primers }
    end
  end

  # GET /primers/1
  # GET /primers/1.json
  def show
    @primer = Primer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @primer }
    end
  end

  # GET /primers/new
  # GET /primers/new.json
  def new
    @primer = Primer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @primer }
    end
  end

  # GET /primers/1/edit
  def edit
    @primer = Primer.find(params[:id])
  end

  # POST /primers
  # POST /primers.json
  def create
    @primer = Primer.new(params[:primer])

    respond_to do |format|
      if @primer.save
        format.html { redirect_to @primer, notice: 'Primer was successfully created.' }
        format.json { render json: @primer, status: :created, location: @primer }
      else
        format.html { render action: "new" }
        format.json { render json: @primer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /primers/1
  # PUT /primers/1.json
  def update
    @primer = Primer.find(params[:id])

    respond_to do |format|
      if @primer.update_attributes(params[:primer])
        format.html { redirect_to @primer, notice: 'Primer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @primer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /primers/1
  # DELETE /primers/1.json
  def destroy
    @primer = Primer.find(params[:id])
    @primer.destroy

    respond_to do |format|
      format.html { redirect_to primers_url }
      format.json { head :no_content }
    end
  end
end
