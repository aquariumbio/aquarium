

class TechnicianController < ApplicationController

  before_filter :signed_in_user

  def index
    respond_to do |format|
      @job_id = params[:job_id]
      format.html { render layout: 'aq2' }
    end
  end

end
