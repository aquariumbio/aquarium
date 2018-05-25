class ProtocolTreeController < ApplicationController

  before_filter :signed_in_user

  def file
  end

  def recent
    @jobs = Job.where("user_id = :user AND created_at >= :date", { user: current_user, date: Time.now.weeks_ago(1) }).reverse_order
    @recents = []
    @jobs.each do |j|
      @recents.push({
                      path: j.path,
                      sha: j.sha,
                      args: args = (JSON.parse(j.state))['stack'].first.reject { |k, v| k == 'user_id' }
                    })
    end

    @recents.uniq!

  end

end
