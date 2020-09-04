# typed: true
# frozen_string_literal: true

class TechnicianDashboardController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def index
    respond_to do |format|
      format.json do
        render json: Operation.where(status: %w[pending scheduled running primed])
                              .as_json(methods: %i[field_values plans precondition_value])
      end
      format.html { render layout: 'aq2' }
    end
  end
end
