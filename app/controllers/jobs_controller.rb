class JobsController < ApplicationController

  before_filter :signed_in_user

  def index

    @users = User.all - User.includes(memberships: :group).where(memberships: { group_id: Group.find_by(name: 'retired') })
    @groups = Group.includes(:memberships).all.reject { |g| g.memberships.length == 1 }
    @metacols = Metacol.where(status: 'RUNNING')

  end

  def joblist
    logger.info params
    render json: JobsDatatable.new(view_context)
  end

  def show

    begin
      @job = Job.find(params[:id])
    rescue StandardError
      redirect_to logs_path
      return
    end

    return redirect_to krill_log_path(job: @job.id) if /\.rb$/ =~ @job.path

    @group = (Group.find_by(id: @job.group_id) if @job.group_id)

    @user = (User.find_by(id: @job.user_id) if @job.user_id.to_i >= 0)

    @submitter = (User.find_by(id: @job.submitted_by) if @job.submitted_by)

    @status = @job.status

  end

  def destroy
    Job.find(params[:id]).destroy
    flash[:success] = "Job #{params[:id]} has been cancelled."
    redirect_to jobs_url
  end

  def summary

    if params[:sha]

      @jobs = Job.where('path = ? AND sha = ?', params[:path], params[:sha])

      if /local_file/ =~ params[:sha]
        blob = Blob.get params[:sha], params[:path]
        @content = blob.xml.force_encoding('UTF-8')
      else
        begin
          @content = Repo.contents params[:path], params[:sha]
        rescue Exception => e
          @content = "Could not find '#{params[:path]}' with sha '#{params[:sha]}' in master branch.<br />"
          @content += '    This protocol may have been run from a development branch that has not yet been merged with master.'
          @content = @content.html_safe
        end
      end

    elsif params[:path]

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

    else

      @paths = (Job.uniq.pluck(:path).reject { |p| !p || /\.pdl$/ =~ p || /\.pl$/ =~ p }).sort

    end

  end

  def upload
    redirect_to Upload.find(params[:id]).url
  end

end
