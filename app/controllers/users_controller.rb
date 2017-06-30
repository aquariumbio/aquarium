class UsersController < ApplicationController

  before_filter :signed_in_user, only: [:edit, :update]
  before_filter :signed_in_user, only: [:index, :edit, :update]
  before_filter :admin_user,     only: [:destroy, :new, :password, :index]

  def new
    @user = User.new
  end

  def password
    @user = User.new
    render 'password'
  end

  def show
    @user = User.find(params[:id])

    if params[:keygen] && @user.id == current_user.id
      @user.generate_api_key
      @user.reload
      redirect_to @user
      return
    end

    render layout: 'aq2'

  end

  def billing

    @user = User.find(params[:id])
    @report = TaskPrototype.cost_report @user.id

    respond_to do |format|
      format.html
      format.json { render json: @report }
    end    

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
        redirect_to users_path
      else
        flash[:error] = "#{params[:user][:login]}'s password not changed."
        redirect_to password_path
      end

    end

  end

  def edit
  end

  def update

    user = User.find(params[:id])

    unless user.id == current_user.id || current_user.is_admin
      render json: { error: "User #{current_user.login} is not authorized to update user #{user.login}'s profile." }, status: 422
      return
    end

    if params[:name] != user.name
      user.name = params[:name]
      user.save
      unless user.errors.empty?
        render json: { error: user.errors.full_messages.join('') }, status: 422
        return
      end
    end

    params[:parameters].each do |p|
      plist = Parameter.where(user_id: user.id, id: p[:id])
      if plist.length == 0 
        user.parameters.create key: p[:key], value: p[:value]
      elsif plist.length == 1 
        plist[0].value = p[:value]
        plist[0].save
        unless plist[0].errors.empty?
          render json: { error: plist[0].errors.full_messages.join('') }
          return
        end        
      end
    end

    render json: user

  end

  def update_password

    user = User.find(params[:id])

    unless user.id == current_user.id || current_user.is_admin
      render json: { error: "User #{current_user.login} is not authorized to change #{user.login}'s password." }, status: 422
      return
    end

    user.password = params[:password]
    user.password_confirmation = params[:password_confirmation]
    user.save

    if user.errors.empty?
      redirect_to :users_url
    else
      render json: { error: user.errors.full_messages.join(', ') }, status: 422
    end

  end

  def index

    @user = User.new

    respond_to do |format|

      format.html {

        retired = Group.find_by_name('retired')
        rid = retired ? retired.id : -1

        @users = User.includes(memberships: :group)
                     .select { |u| !u.member? rid }
                     .sort { |a,b| a[:login] <=> b[:login] }
                     .paginate(page: params[:page], :per_page => 15)    

        render layout: 'aq2' 

      }
      format.json { render json: User.includes(memberships: :group).all.sort { |a,b| a[:login] <=> b[:login] } }

    end

  end

  def current
    u = current_user
    u[:memberships] = current_user.groups
    render json: u
  end

  def destroy

    u = User.find(params[:id])
    ret = Group.find_by_name('retired')

    if ret
      m = Membership.new
      m.user_id = u.id
      m.group_id = ret.id
      m.save    
      flash[:success] = "The user has been disconnected. Why did they resist? We only wish to raise quality of life for all species."
    else 
      flash[:error] = "Could not retire user because the 'retired' group does not exist. Go make it and try again."
    end

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
