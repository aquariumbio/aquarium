class StatsController < ApplicationController

  before_filter :signed_in_user

  def jobs

    now = Time.now

    render json: {
      active: Job.where('pc >= 0'),
      urgent: Job.where('pc = -1 AND latest_start_time < ?', now),
      pending: Job.where('pc = -1 AND desired_start_time < ? AND ? <= latest_start_time', now, now),
      later: Job.where('pc = -1 AND ? <= desired_start_time', now)
    }

  end

  def users

    data = {}
    now = Time.now

    User.includes(:jobs).each do |u|
      data[u.login] = (u.jobs.select { |j| j.created_at > now - 7.days }).length
    end

    render json: data

  end

  def summarize_jobs(jobs)

    p = {}

    jobs.each do |j|
      path = if j.path
               j.path.split('/').last
             else
               'unknown'
             end
      if p[path]
        p[path] += 1
      else
        p[path] = 1
      end
    end

    p

  end

  def user_activity

    jobs = Job.includes(:logs).where('user_id = ? AND pc = -2 AND created_at > ?', params[:user_id], Time.now - 100.days)
    protocol_usage = summarize_jobs jobs

    completions = []

    (0..99).each do |day|
      t1 = (Time.now - day.days).to_i
      t2 = (Time.now - (day - 1).days).to_i
      num = (jobs.select { |j| t1 < j.updated_at.to_i && j.updated_at.to_i <= t2 }).length
      completions.push([t1 * 1000, num])
    end

    render json: {
      protocol_usage: protocol_usage.sort_by { |_key, value| value },
      completions: completions
    }

  end

  def protocols

    now = Time.now
    p = summarize_jobs(Job.where('created_at > ?', now - 28.days))
    render json: p.sort_by { |_key, value| value }

  end

  def outcomes

    now = Time.now

    r = { 'ERROR' => 0, 'ABORTED' => 0, 'COMPLETED' => 0, 'CANCELED' => 0 }
    Job.where('pc = -2 AND created_at > ?', now - 7.days).each do |j|
      r[j.status] += 1
    end

    render json: r.sort

  end

  def samples

    r = {}

    data = SampleType.includes(samples: [:items]).collect do |st|
      num_items = 0
      st.samples.each do |s|
        num_items += (s.items.reject { |i| i.quantity <= 0 }).length
      end
      r[st.name] = [st.samples.length, num_items]
    end

    render json: r

  end

  def objects

    t = ObjectType.first.created_at
    now = Time.now

    objects = []
    items = []

    while t < now
      tnew = t + 14.days
      objects.push([1000 * t.to_i, ObjectType.where('created_at < ?', tnew).count])
      items.push([1000 * t.to_i, Item.where('created_at < ? AND quantity >= 0', tnew).count])
      t = tnew
    end

    render json: { objects: objects, items: items }

  end

  def processes

    names = []
    active = []
    pending = []
    completed = []

    Metacol.where("status='RUNNING'").each do |m|
      login = User.find_by_id(m.user_id).login
      name = if m.path
               m.path.split('.').first
             else
               'unknown'
             end
      names.push("#{m.id}:#{name}<br />(#{login})")
      active.push((m.jobs.select { |j| j.pc >= 0 }).length)
      pending.push((m.jobs.select { |j| j.pc >= -1 }).length)
      completed.push((m.jobs.select { |j| j.pc >= -2 }).length)
    end

    render json: { names: names, active: active, pending: pending, completed: completed }

  end

  def user_items

    items = Item.joins(:sample).where(
      object_type_id: params[:object_type_id].to_i,
      samples: { user_id: params[:user_id].to_i }
    )

    data = []

    data.push [1000 * (items.first.created_at - 1.day).to_i, 0] unless items.empty?

    items.each do |i|
      data.push [1000 * i.created_at.to_i, data.last[1] + 1]
    end

    render json: data

  end

  def protocol_version_info

    @infos = {}

    Job.where(path: params[:path]).reverse.each do |j|
      @infos[j.sha] = if !@infos[j.sha]
                        {
                          num: 1,
                          successes: j.error? ? 0 : 1,
                          first: j.created_at,
                          last: j.created_at
                        }
                      else
                        {
                          num: @infos[j.sha][:num] + 1,
                          successes: @infos[j.sha][:successes] + (j.error? ? 0 : 1),
                          last: @infos[j.sha][:last],
                          first: j.created_at
                        }
                      end
    end

    @infos.each do |k, _v|
      @infos[k][:posts] = PostAssociation.where(sha: k).count
    end

    render json: @infos

  end

end
