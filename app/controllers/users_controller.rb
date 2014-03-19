class ProductionUser < User
end

class ProductionGroup < Group
end

class ProductionMembership < Membership
end

class UsersController < ApplicationController

  before_filter :signed_in_user, only: [:edit, :update]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :signed_in_user, only: [:index, :edit, :update]
  before_filter :admin_user,     only: :destroy
  before_filter :admin_user,     only: :new

  def new
    @user = User.new
  end

  def password
    @user = User.new
    render 'password'
  end

  def show
    @user = User.find(params[:id])
  end

  def create

    if !params[:change_password]

      @user = User.new(params[:user])

      if @user.save
        @group = Group.new
        @group.name = @user.login
        @group.description = "A group containing only user #{@user.name}"
        @group.save
        m = Membership.new
        m.group_id = @group.id
        m.user_id = @user.id
        m.save
        flash[:success] = "#{params[:user][:name]} has been assimilated."
        redirect_to @user
      else
        render 'new'
      end
 
    else

      @user = User.find_by_login(params[:user][:login])
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      if @user.save
        flash[:success] = "#{params[:user][:login]}'s password changed."
        redirect_to @user
      else
        flash[:error] = "#{params[:user][:login]}'s password not changed."
        redirect_to password_path
      end

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
    @users = User.paginate(page: params[:page], :per_page => 20).order('login ASC')
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "The user has been disconnected. Why did he resist? We only wish to raise quality of life for all species."
    redirect_to users_url
  end

  def copy_users_from_production
    
    if Rails.env != 'production'

      # Delete current users 
      User.all.each do |u|
        u.destroy
      end
    
      # Delete current groups
      Group.all.each do |g|
        g.destroy # should destroy memberships too
      end

      # Delete current memberships just in case there are some left
      Membership.all.each do |m|
        m.destroy 
      end

      # Copy users
      ProductionUser.switch_connection_to(:production_server)

      ProductionUser.all.each do |u|
        new_user = User.new
        new_user.copy u
      end

      # Copy groups
      ProductionGroup.switch_connection_to(:production_server)

      ProductionGroup.all.each do |g|
        new_group = Group.new(g.attributes.except("created_at","updated_at"))
        new_group.id = g.id
        new_group.save
      end

      # Copy memberships
      ProductionMembership.switch_connection_to(:production_server)

      ProductionMembership.all.each do |m|
        new_mem = Membership.new(m.attributes.except("created_at","updated_at"))
        new_mem.id = m.id
        begin
          new_mem.save
        rescue Exception => e
          logger.info "ERROR: Could not insert #{new_mem.inspect}"
          flash[:error] = "ERROR: Could not insert #{new_mem.inspect}"
        end
      end

      redirect_to production_interface_path, notice: "#{User.all.length} users and #{Group.all.length} groups copied."

    else
   
      redirect_to production_interface_path, notice: "This functionality is not available in production mode."

    end

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
