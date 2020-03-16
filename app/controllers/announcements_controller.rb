# frozen_string_literal: true

class AnnouncementsController < ApplicationController

  before_filter :signed_in_user

  before_filter do
    redirect_to root_path, notice: 'Administrative privileges required to access budgets.' unless current_user && current_user.is_admin
  end

  # GET /announcements
  # GET /announcements.json
  def index
    @announcements = Announcement.all
    @latest_announcement = @announcements.last
    @announcement = Announcement.new

    respond_to do |format|
      format.html { render layout: 'aq2' }
      format.json { render json: @announcements }
    end
  end

  # GET /announcements/1/edit
  def edit
    @announcement = Announcement.find(params[:id])
    render layout: 'aq2'
  end

  # POST /announcements
  # POST /announcements.json
  def create
    @announcement = Announcement.new(params[:announcement])

    respond_to do |format|
      if @announcement.save
        format.html { redirect_to announcements_path, notice: 'Announcement was successfully created.' }
        format.json { render json: @announcement, status: :created, location: @announcement }
      else
        format.html { render layout: 'aq2', action: 'new' }
        format.json { render json: @announcement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /announcements/1
  # PUT /announcements/1.json
  def update
    @announcement = Announcement.find(params[:id])

    respond_to do |format|
      if @announcement.update_attributes(params[:announcement])
        format.html { redirect_to announcements_path, notice: 'Announcement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @announcement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /announcements/1
  # DELETE /announcements/1.json
  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.destroy

    respond_to do |format|
      format.html { redirect_to announcements_url }
      format.json { head :no_content }
    end
  end
end
