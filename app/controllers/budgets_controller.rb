class BudgetsController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user    

  before_filter {
    unless current_user && current_user.is_admin
      redirect_to root_path, notice: "Administrative privileges required to access budgets."
    end
  }

  # GET /budgets
  # GET /budgets.json
  def index
    @budgets = Budget.all
    @budget = Budget.new

    respond_to do |format|
      format.html { render layout: 'aq2' } # index.html.erb
      format.json { render json: @budgets }
    end
  end

  # GET /budgets/1
  # GET /budgets/1.json
  def show

    @budget = Budget.find(params[:id])
    @users = (User.all.reject { |u| u.retired? }).sort { |a,b| a[:login] <=> b[:login] }

    respond_to do |format|
      format.html { render layout: 'aq2' } 
      format.json { render json: @budget }
    end

  end

  # GET /budgets/new
  # GET /budgets/new.json
  def new
    @budget = Budget.new

    respond_to do |format|
      format.html { render layout: 'aq2' } 
      format.json { render json: @budget }
    end
  end

  # GET /budgets/1/edit
  def edit
    @budget = Budget.find(params[:id])
    respond_to do |format|
      format.html { render layout: 'aq2' } 
      format.json { render json: @budget }
    end    
  end

  # POST /budgets
  # POST /budgets.json
  def create
    @budget = Budget.new(params[:budget])

    respond_to do |format|
      if @budget.save
        format.html { redirect_to @budget, notice: 'Budget was successfully created.' }
        format.json { render json: @budget, status: :created, location: @budget }
      else
        format.html { render action: "new" }
        format.json { render json: @budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /budgets/1
  # PUT /budgets/1.json
  def update
    @budget = Budget.find(params[:id])

    respond_to do |format|
      if @budget.update_attributes(params[:budget])
        format.html { redirect_to @budget, notice: 'Budget was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /budgets/1
  # DELETE /budgets/1.json
  def destroy
    @budget = Budget.find(params[:id])
    @budget.destroy

    respond_to do |format|
      format.html { redirect_to budgets_url }
      format.json { head :no_content }
    end
  end

  def add_user
    if current_user.is_admin
      uba = UserBudgetAssociation.new
      uba.budget_id = params[:bid].to_i
      uba.user_id = params[:uid].to_i
      uba.quota = params[:quota].to_i
      uba.disabled = false;
      uba.save
    else
      flash[:warning] = "Only admins can add users to budgets"
    end
    redirect_to Budget.find(params[:bid])
  end

  def remove_user
    if current_user.is_admin
      ubas = UserBudgetAssociation.where(budget_id: params[:bid].to_i, user_id: params[:uid])
      if ubas.length > 0
        ubas[0].destroy
      end
    else
      flash["warning"] = "Only admins can remove users from budgets"
    end
    redirect_to Budget.find(params[:bid])
  end  

end
