class ApiController < ApplicationController

  def main
    render json: Oj.dump((Api.new params).run, mode: :compat)
  end

end

