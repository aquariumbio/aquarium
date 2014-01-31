class SamplesController < ApplicationController

  before_filter :signed_in_user

  # GET /samples
  # GET /samples.json
  def index

    # What are the sample types?
    @all_sample_types = SampleType.all

    # Figure out which user's samples we're looking at
    @sample_type_id = params[:sample_type_id] ? params[:sample_type_id] : @all_sample_types.first.id

    @sample_type = SampleType.find(@sample_type_id)

    # Figure out which user's samples we're looking at
    @user_id = params[:user_id] ? params[:user_id].to_i : -1

    if @user_id >= 0
      @user = User.find(@user_id)
      @samples = Sample.where("sample_type_id = :s AND user_id = :u", { s: @sample_type_id, u: @user.id })
    else
      @user = nil
      @samples = Sample.where("sample_type_id = :s", s: @sample_type_id)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @samples }
    end

  end

  # GET /samples/1
  # GET /samples/1.json
  def show

    @sample = Sample.find(params[:id])
    @sample_type = @sample.sample_type

    if params[:toggle] 
      @item = Item.find(params[:toggle])
      @item.inuse = @item.inuse > 0 ? 0 : 1;
      @item.save
    end

    if params[:delete] 
      i = Item.find(params[:delete])
      puts "DELETING ITEM #{i.id}"
      flash[:notice] = "Deleted item #{i.id}"
      i.quantity = -1
      i.inuse = -1
      i.location = 'deleted'
      i.save!
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sample }
    end

  end

  # GET /samples/new
  # GET /samples/new.json
  def new

    @sample = Sample.new
    @user = User.find(current_user)
    @sample.sample_type_id = params[:sample_type]
    @sample_type = @sample.sample_type

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sample }
    end

  end

  # GET /samples/1/edit
  def edit
    @sample = Sample.find(params[:id])
    @user = User.find(current_user)
    @sample_type = @sample.sample_type
  end

  # POST /samples
  # POST /samples.json
  def create

    @sample = Sample.new(params[:sample])
    @user = User.find(current_user)
    @sample_type = @sample.sample_type

    respond_to do |format|
      if @sample.save
        format.html { redirect_to @sample, notice: 'Sample was successfully created.' }
        format.json { render json: @sample, status: :created, location: @sample }
      else
        format.html { render action: "new" }
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /samples/1
  # PUT /samples/1.json
  def update
    @sample = Sample.find(params[:id])

    respond_to do |format|
      if @sample.update_attributes(params[:sample])
        format.html { redirect_to @sample, notice: 'Sample was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /samples/1
  # DELETE /samples/1.json
  def destroy

    @sample = Sample.find(params[:id])
    id = @sample.sample_type_id

    if @sample.items.length > 0 
      flash[:notice] = "Could not delete sample #{@sample.name} because there are items associated with it."
    else
      @sample.destroy
    end

    respond_to do |format|
      format.html { redirect_to samples_url(sample_type_id: id) }
      format.json { head :no_content }
    end
  end

  def project

    if !params[:name]

      @projects = Sample.uniq.pluck(:project).sort

    else

      @samples = Sample.where('project = ?', params[:name]).sort { |a,b|
        [ a.sample_type.name, a.name ] <=> [ b.sample_type.name, b.name ]
      }

    end

  end

  def spreadsheet
  end

  def schema sample_type

    fields = [ 'name', 'project', 'user' ]

    (1..8).each do |i| 
      fn = "field#{i}name".to_sym
      ft = "field#{i}type".to_sym 
      f = "field#{i}".to_sym 

      if sample_type[ft] != 'not used' && sample_type[ft] !=nil 
        fields.push sample_type[ft]
      else
        fields.push :unused
      end

    end

    fields.reject { |f| f == :unused }

  end

  def make_samples data

    samples = []

    if data.length == 0
      redirect_to spreadsheet_path, notice: "File contains no parsable data"
    end

    name = data.shift[0]
    @sample_type = SampleType.find_by_name(name)
    @schema = schema @sample_type

    if !@sample_type
      redirect_to spreadsheet_path, notice: "Could not find sample type #{name}"
    end

    data.each do |row|

      sample_name = row[0]
      project = row[1]
      login = row[2]

      if row.length != @schema.length
        redirect_to spreadsheet_path, notice: "This row has the wrong number of fields: #{row}."
        return []
      elsif Sample.find_by_name(sample_name)
        redirect_to spreadsheet_path, notice: "The sample name #{sample_name} is already taken."
        return []
      elsif !User.find_by_login(login)
        redirect_to spreadsheet_path, notice: "Could not find user with login #{login}."
        return []
      end

      sample = Sample.new
      sample.name = sample_name
      sample.project = project
      sample.user_id = User.find_by_login(login).id
      sample.sample_type_id = @sample_type.id

      (3..(@schema.length-1)).each do |i|
        ff = "field#{i-2}".to_sym
        sample[ff] = row[i]
      end

      samples.push sample

    end

    samples

  end

  def process_spreadsheet

    if !params[:spreadsheet]
      redirect_to spreadsheet_path, notice: "No path specified"
    else

      path = params[:spreadsheet].original_filename
      content = params[:spreadsheet].read
      @data = content.split(/\n|\r/).collect do |l|
        l.split(/,\s*/)
      end

      @samples = make_samples @data

      if @samples.length > 0
        @samples.each do |s|
          s.save
        end
      end

    end

  end

end

