class RepoController < ApplicationController

  before_filter :signed_in_user

  def directory_hash(path, name=nil)
    data = {:data => (name || path)}
    data[:children] = children = []
    Dir.entries(path).sort.each do |entry|
      next if ( /^\./ =~ entry )
      full_path = File.join(path, entry)
      if File.directory?(full_path)
        children << directory_hash(full_path, entry)
      elsif /.pl$|.oy$|.kl$/ =~ entry
        children << entry
      end
    end
    return data
  end

  def list

    @repos = directory_hash('repos')

    @repos[:children].each do |r|
      r[:info] = Repo::info( r[:data] )
    end

    if params[:highlight]
      @highlight = params[:highlight]
    else
      @highlight = @repos[:children].last[:data]
    end

    respond_to do |format|
      format.html
    end

  end

  
  def get

    begin
      @version = Repo::version(params[:path])
    rescue
      flash[:error] = "The file #{params[:path]} exists but is not under version control. Do you need to commit it?"
      redirect_to repo_list_path
      return
    end

    if /\.pl$/ =~ params[:path]
      if params[:from]
        sequence_new_job @version, params[:path], params[:from].to_i
      else
        redirect_to interpreter_arguments_path(sha: @version, path: params[:path]) 
      end
    else
      redirect_to arguments_new_metacol_path(sha: @version, path: params[:path])
    end
    
  end 

  def pull

    begin
      flash[:notice] = Git.open("repos/"+params[:name]).pull().gsub(/\r|\n/,"<br />").html_safe
    rescue Exception => e
      flash[:notice] = "Could not pull: this repository may not have a non-local origin associated with it."
    end
    redirect_to repo_list_path( highlight: params[:name])

  end

end
