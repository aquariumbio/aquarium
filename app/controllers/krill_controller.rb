class KrillController < ApplicationController

  before_filter :signed_in_user

  def start

    @job = Job.find(params[:job])

    # if not running, then start
    if @job.pc == Job.NOT_STARTED

      @job.user_id = current_user.id
      @job.save

      # Tell Krill server to start protocol
      begin
        server_result = (Krill::Client.new.start params[:job])
      rescue Exception => e
        return redirect_to krill_error_path(job: @job.id, message: e.to_s, backtrace: e.backtrace[0, 2])
      end

      if !server_result
        return redirect_to krill_error_path(job: @job.id, message: 'Krill server returned nil, which is a bad sign.', backtrace: [])
      elsif server_result[:error]
        logger.info server_result[:error]
        return redirect_to krill_error_path(
          job: @job.id,
          message: ('server error: ' + server_result[:error][0, 512]).html_safe,
          backtrace: []
        )
      end

    end

    # redirect to ui
    redirect_to "/technician/#{params[:job]}"

  end

  def debug

    errors = []
    @job = Job.find(params[:id])

    # if not running, then start
    if @job.pc == Job.NOT_STARTED

      @job.user_id = current_user.id
      @job.save

      begin
        manager = Krill::Manager.new @job.id, true, 'master', 'master'
      rescue Exception => e
        error = e
      end

      if error
        errors << error
      else

        begin
          manager.run
        rescue Exception => e
          errors << e.message
        end

      end

    end

    Operation.step @job.operations.collect { |op| op.plan.operations }.flatten

    render json: { errors: errors, operations: @job.reload.operations, job: @job }

  end

  def error

    @message = params[:message]
    @backtrace = params[:backtrace] || []
    @job = Job.find(params[:job])

    respond_to do |format|
      format.html { render layout: 'aq2-plain' }
    end

  end

  def state

    @job = Job.find(params[:job])
    render json: { state: (JSON.parse @job.state), result: { response: 'n/a' } }

  end

  def abort

    begin
      result = Krill::Client.new.abort params[:job]
    rescue Exception => e
      result = { response: 'error', message: e.to_s }
    else
      @job = Job.find(params[:job])
      @job.stop 'error'
      @job.operations.each do |op|
        op.associate :aborted, "Operation was canceled when job #{@job.id} was aborted"
      end

      state = JSON.parse @job.state, symbolize_names: true
      if state.length.odd? # backtrace ends with a 'next'
        @job.append_step operation: 'display', content: [
          { title: 'Interrupted' },
          { note: "This step was being prepared by the protocol when the 'abort' signal was received." }
        ]
      end

      # add next and final
      @job.append_step operation: 'next', time: Time.now, inputs: {}
      @job.append_step operation: 'aborted', rval: {}

      logger.info "ABORTING KRILL JOB #{@job.id}"
    end

    render json: result

  end

  def jobs

    begin
      result = Krill::Client.new.jobs
    rescue Exception => e
      result = { response: 'error', message: e.to_s }
    end

    render json: result

  end

  def next

    @job = Job.find(params[:job])

    if @job.pc >= 0

      state = JSON.parse @job.state, symbolize_names: true

      unless state.last[:operation] == 'next' || params[:command] == 'check_again'
        inputs = params[:inputs]
        inputs[:table_inputs] = [] unless inputs[:table_inputs]
        state.push(
          operation: params[:command],
          time: Time.now,
          inputs: inputs # JSON.parse(params[:inputs], symbolize_names: true)
        )
        @job.state = state.to_json
        @job.save
      end

      # Tell Krill server to continue in the protocol
      begin
        result = (Krill::Client.new.continue params[:job])
      rescue Exception => e
        result = { response: 'error', error: "Call to server raised #{e}" }
      end

      result ||= { response: 'error', error: 'Server returned nil, a bad sign.' }

      if result[:response] == 'done'

        Thread.new do # this goes in the background because it can take a
          # while, and the technician interface should not have
          # to wait
          Operation.step(@job.all_operations) # defined in models/Operation.rb
        end

      end

      @job.reload

    else

      result = { response: 'error', error: 'Job is no longer running.' }

    end

    render json: { state: (JSON.parse @job.state), result: result }

  end

  def log

    begin
      @job = Job.includes(:user, :group, :uploads).find(params[:job])
    rescue StandardError
      redirect_to logs_path
      return
    end

    @group = @job.group
    @submitter = User.find(@job.submitted_by)
    @performer = @job.user

    @history = @job.state.gsub('Infinity', '"Inf"')
    @rval = @job.return_value

    render layout: 'aq2'

  end


  def upload

    u = Upload.new

    File.open(params[:file].tempfile) do |f|
      u.upload = f
      u.name = params[:file].original_filename
      u.job_id = params[:job]
      u.save

      if params[:assoc_operations] == 'true'
        Job.find(params[:job]).operations.each do |operation|
          operation.associate :technician_upload, "File upload #{params[:file].original_filename}", u, duplicates: true
        end
      end

      if params[:assoc_plans] == 'true'
        plan_ids = Job.find(params[:job]).operations.collect { |operation| operation.plan.id }.flatten.uniq
        plans = Plan.find(plan_ids)
        plans.each do |plan|
          plan.associate :technician_upload, "File upload #{params[:file].original_filename}", u, duplicates: true
        end
      end

    end

    unless u.errors.empty?
      logger.info "ERRORS: #{u.errors.full_messages}"
      render json: { error: u.errors.full_messages.to_s }
      return
    end

    render json: u

  end

  def uploads

    render json: { uploads: Job.find(params[:job]).uploads.collect { |u| { id: u.id, name: u.name, url: u.url } } }

  end

end
