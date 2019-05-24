# frozen_string_literal: true

class ImportController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def index
    render layout: 'aq2'
  end

end
