class StatsController < ApplicationController

  def jobs

    now = Time.now

    render json: { 
      active: Job.where("pc >= 0"),
      urgent: Job.where("pc = -1 AND latest_start_time < ?", now),
      pending: Job.where("pc = -1 AND desired_start_time < ? AND ? <= latest_start_time", now, now),
      later: Job.where("pc = -1 AND ? <= desired_start_time", now)
    }

  end

  def users

    data = {}
    now = Time.now

    User.all.each do |u|
      data[u.login] = (u.jobs.select { |j| j.created_at > now - 7.days }).length
    end

    render json: data

  end

  def summarize_jobs jobs

    p = {}

    jobs.each do |j|
      if j.path
        path = j.path.split('/').last
      else
        path = 'unknown'
      end
      if p[path]
        p[path] += 1
      else
        p[path] = 1
      end
    end

    return p

  end

  def user_activity 

    jobs = Job.where("user_id = ? AND pc = -2 AND created_at > ?", params[:user_id], Time.now - 31.days)
    protocol_usage = summarize_jobs jobs

    render json: {
      protocol_usage: protocol_usage.sort_by {|_key, value| -value},
      completions: jobs.collect { |j| { status: j.status, updated: 1000*j.updated_at.to_i } }
    }

  end

  def protocols

    now = Time.now

    p = summarize_jobs( Job.where("created_at > ?", now - 7.days) )

    render json: p.sort_by {|_key, value| -value}

  end

  def outcomes

    now = Time.now

    r = { "ERROR" => 0, "ABORTED" => 0, "COMPLETED" => 0, "CANCELED" => 0 }
    Job.where("pc = -2 AND created_at > ?", now - 7.days).each do |j|
      r[j.status] += 1
    end

    render json: r.sort

  end

  def samples

    r = {}

    data = SampleType.all.collect do |st|
      num_items = 0;
      st.samples.each do |s|
        num_items += (s.items.reject { |i| i.quantity <= 0 }).length
      end
      r[st.name] = [ st.samples.length, num_items ]
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
      objects.push( [ 1000*t.to_i, ObjectType.where("created_at < ?", tnew).length ] )
      items.push( [ 1000*t.to_i, Item.where("created_at < ? AND quantity >= 0", tnew).length  ] )
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
        if m.path
          name = m.path.split('.').first
        else
          name = "unkown"
        end
        names.push( "#{m.id}:#{name}<br />(#{login})" )
        active.push( (m.jobs.select { |j| j.pc >= 0 }).length )
        pending.push( (m.jobs.select { |j| j.pc >= -1 }).length )
        completed.push( (m.jobs.select { |j| j.pc >= -2 }).length )
    end

    render json: { names: names, active: active, pending: pending, completed: completed }

  end

  def empty

    render json: ( ObjectType.all.select { |ot| ot.quantity < ot.min } ).collect { |ot| view_context.link_to( ot.name, ot) }

  end

  def timing

    @job = params[:job]

    render json: (Log.where("job_id = ? AND entry_type = 'NEXT'",@job).collect { |log| [ 1000*(log.created_at.to_i), JSON.parse(log.data)['pc'] ] })

  end

end
