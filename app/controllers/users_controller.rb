# frozen_string_literal: true

class UsersController < ApplicationController

  before_filter :signed_in_user, only: %i[edit update]
  before_filter :signed_in_user, only: %i[index edit update]
  before_filter :admin_user,     only: %i[destroy new password index]

  def new
    @user = User.new

    respond_to do |format|
      format.html { render layout: 'aq2' } # new.html.erb
      format.json { render json: @user }
    end
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
        render layout: 'aq2', action: 'new'
      end

    else

      @user = User.find_by(login: params[:user][:login])
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

  def edit; end

  def update
    user = User.find(params[:id])

    unless user.id == current_user.id || current_user.admin?
      render json: { error: "User #{current_user.login} is not authorized to update user #{user.login}'s profile." }, status: :unprocessable_entity
      return
    end

    if params[:name] != user.name
      user.name = params[:name]
      user.save
      unless user.errors.empty?
        render json: { error: user.errors.full_messages.join('') }, status: :unprocessable_entity
        return
      end
    end

    errors = nil
    params[:parameters].each do |p|
      plist = Parameter.where(user_id: user.id, id: p[:id])
      if plist.empty?
        user.parameters.create key: p[:key], value: p[:value]
      elsif plist.length == 1
        plist[0].value = p[:value]
        plist[0].save
        unless plist[0].errors.empty?
          errors = plist[0].errors
          break
        end
      end
    end

    response = if errors.present?
                 { error: errors.full_messages.join('') }
               else
                 user
               end

    render json: response
  end

  def update_password

    user = User.find(params[:id])

    unless user.id == current_user.id || current_user.admin?
      render json: { error: "User #{current_user.login} is not authorized to change #{user.login}'s password." }, status: :unprocessable_entity
      return
    end

    user.password = params[:password]
    user.password_confirmation = params[:password_confirmation]
    user.save

    if user.errors.empty?
      render json: user
    else
      render json: { error: user.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end

  end

  def index
    @user = User.new

    respond_to do |format|
      format.html do
        @users, @alpha_params = User.all.alpha_paginate(params[:letter], { db_mode: true, db_field: 'name' })
        render layout: 'aq2'
      end
      format.json { render json: User.includes(memberships: :group).all.sort { |a, b| a[:login] <=> b[:login] } }
    end
  end

  def current
    u = current_user.as_json
    u[:memberships] = current_user.groups
    render json: u
  end

  def active
    users = User.select_active
    render json: users.collect { |u| { id: u.id, name: u.name, login: u.login } }
  end

  def destroy
    user = User.find(params[:id])

    if user
      user.retire
      flash[:success] = 'The user has been disconnected. Why did they resist? We only wish to raise quality of life for all species.'
    else
      flash[:error] = 'Cannot retire user that does not exist.'
    end

    redirect_to users_url
  end

  def stats
    render json: User.find(params[:id]).stats
  end

  private

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path, notice: "You cannot edit someone else's profile") unless current_user?(@user)
  end

  def admin_user
    flash[:error] = 'You do not have admin privileges' unless current_user.admin?
    redirect_to(root_path) unless current_user.admin?
  end

end
