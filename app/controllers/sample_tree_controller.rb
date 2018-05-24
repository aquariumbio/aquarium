class SampleTreeController < ApplicationController

  before_filter :signed_in_user

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json do
        st = SampleTree.new params[:id]
        st.expand
        render json: st.as_json
      end
    end
  end

  def jobs
    item = Item.includes(:sample).find(params[:id])
    touches = Touch.where(item_id: item.id)
    jobs = touches.collect do |t|
      job = Job.where(id: t.job_id).pluck_all(:id, :user_id, :created_at, :updated_at, :path).first.symbolize_keys
      Rails.logger.info job
      job[:user_login] = User.find(job[:user_id]).login
      job[:tasks] = Touch.where(job_id: job[:id]).select(&:task_id).collect do |t|
        Task.includes(:task_prototype).find(t.task_id)
      end.select { |task| task.references?(item) }.collect do |task|
        t = task.as_json
        t[:user_login] = task.user.login
        t
      end
      job
    end
    render json: jobs.uniq
  end

  def annotate
    @item = Item.find(params[:id])
    @item.annotate(note: params[:note])
    render json: @item.datum
  end

  def samples
    sample_list = Sample.all
    projects = sample_list.collect(&:project).uniq.sort
    render json: {
      sample_types: SampleType.all,
      samples: sample_list.collect do |s|
        {
          id: s.id,
          name: s.name,
          sample_type_id: s.sample_type_id,
          project: s.project
        }
      end,
      projects: projects
    }
  end

end
