class StaticPagesController < ApplicationController

  def home
  end

  def help
  end

  def about
  end

  def jobchart

    jobs = Job.where("( :newmin < created_at AND created_at < :oldmin) OR created_at > :max", 
                     { newmin: Time.at(params[:newmin].to_i),
                       oldmin: Time.at(params[:oldmin].to_i),
                       max: Time.at(params[:max].to_i) } )

    result = {}

    jobs.all.each do |j|

      start_entry = j.logs.reject { |l| l.entry_type != 'START' }
      stop_entry = j.logs.reject { |l| l.entry_type != 'STOP' }

      if start_entry.length > 0 
        j[:start] = start_entry.first.created_at.to_i
      else
        j[:start] = "0"
      end

      if stop_entry.length > 0 
        j[:stop] = stop_entry.first.created_at.to_i
      else
        j[:stop] = "0"
      end

      begin
        login = User.find(j[:user_id]).login.to_sym
      rescue
        login = :unknown
      end

      unless result.has_key? login 
        result[login] = []
      end

      result[login].push( { job: j[:id], start: j[:start], stop: j[:stop] } )

    end

    respond_to do |format|
      format.html
      format.json { render json: result }
    end

  end

end
