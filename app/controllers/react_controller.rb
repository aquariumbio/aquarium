# typed: false
# frozen_string_literal: true

class ReactController < ApplicationController

  before_filter :signed_in_user

  def index

    render :layout => false
  end

end
