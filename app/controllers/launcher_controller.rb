class LauncherController < ApplicationController

  before_filter :signed_in_user

  def index
    respond_to do |format|
      format.html { render layout: 'browser' }
    end
  end

end