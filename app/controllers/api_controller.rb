class ApiController < ApplicationController 

  def main
    render json: (Api.new params).run
  end

end

