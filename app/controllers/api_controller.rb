class ApiController < ApplicationController

  before_filter :set_headers

  def main
    render json: Oj.dump((Api.new params).run, mode: :compat)
  end

  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST'
    headers['Access-Control-Max-Age'] = '86400'
  end

end

