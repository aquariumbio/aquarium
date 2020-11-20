# frozen_string_literal: true

# typed: strict

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end
