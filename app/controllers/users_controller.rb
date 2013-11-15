class UsersController < ApplicationController

  before_filter :signed_in_user, only: [:edit, :update]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :signed_in_user, only: [:index, :edit, :update]
  before_filter :admin_user,     only: :destroy
  before_filter :admin_user,     only: :new

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "#{params[:user][:name]} has been assimilated."
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "The user has been disconnected. Why did he resist? We only wish to raise quality of life for all species."
    redirect_to users_url
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path, notice: "You cannot edit someone else's profile") unless current_user?(@user)
    end

    def admin_user
      flash[:error] = "You do not have admin privileges" unless current_user.is_admin
      redirect_to(root_path) unless current_user.is_admin
    end

end
