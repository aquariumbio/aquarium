# frozen_string_literal: true

class GroupsController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  # GET /groups
  # GET /groups.json
  def index
    respond_to do |format|
      format.html do
        @groups, @alphaParams = Group.non_user_groups.alpha_paginate(params[:letter], { db_mode: true, db_field: "name" })
        render layout: 'aq2'
      end
      format.json { render json: Group.non_user_groups.includes(memberships: :group).sort { |a, b| a[:name] <=> b[:name] } }
    end
  end

  def names
    render json: Group.list_names
  end

  # GET /groups/1
  # GET /groups/1.json
  def show

    @group = Group.find_by(id: params[:id])

    # Add new users
    if params[:user_id]

      m = Membership.find_by(user_id: params[:user_id], group_id: @group.id)

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

      m = Membership.find_by(user_id: params[:drop_user], group_id: @group.id)

      m.destroy if m

    end

    respond_to do |format|
      format.html { render layout: 'aq2' } # show.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new

    respond_to do |format|
      format.html { render layout: 'aq2' } # new.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
    respond_to do |format|
      format.html { render layout: 'aq2' }

    end
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
        format.html { render layout: 'aq2', action: 'new' }
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
