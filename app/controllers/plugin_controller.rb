class PluginInterfaceBase

  def initialize(view)
    @view = view
  end

  def view
    @view
  end

end

class PluginController < ApplicationController

  before_filter :signed_in_user

  def get part

    path = "#{params[:path]}/#{part}"
    sha = Repo::version path
    Repo::contents path,sha

  end

  def show

    begin
      @layout = get "layout.html"
      @code = get "code.js"
    rescue Exception => e
      @error = e.message
    end

    render layout: "plugin.html.erb"

  end

  def tester
    logger.info "HERE"
    @path = "whatever/plugins/hello"
    render layout: "application.html.erb"
  end

  def ajax

    begin
      control = get "interface.rb"
      ns = Krill::make_namespace control
      plugin = ns::PluginInterface.new view_context
      data = plugin.data(JSON.parse(params[:params],symbolize_names:true))
    rescue Exception => e
      render json: { error: e.message }
    else
      render json: data
    end

  end

end
