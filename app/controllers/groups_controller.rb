# frozen_string_literal: true

class GroupsController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  def names
    render json: Group.list
  end

  # GET /groups/1
  # GET /groups/1.json
  def show

    @group = Group.find_by_id(params[:id])

    # Add new users
    if params[:user_id]

      m = Membership.find_by_user_id_and_group_id(params[:user_id], @group.id)

      unless m

        u = User.find(params[:user_id])
        m = Membership.new
        m.user_id = u.id
        m.group_id = @group.id
        m.save
        # flash[:notice] = "Added #{u.login} to #{@group.name}."

      end

    end

    # Delete users
    if params[:drop_user]

      m = Membership.find_by_user_id_and_group_id(params[:drop_user], @group.id)

      m.destroy if m

    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: 'new' }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end
end
