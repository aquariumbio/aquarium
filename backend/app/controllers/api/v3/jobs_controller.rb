# frozen_string_literal: true

# TODO: move SQL queries to job.rb model
# @api api.v3
module Api
  module V3
    # Job API calls.
    #
    # <b>General</b>
    #   API Status Codes:
    #
    #     STATUS_CODE: 200 - OK
    #     STATUS_CODE: 201 - Created
    #     STATUS_CODE: 401 - Unauthorized
    #     STATUS_CODE: 403 - Forbidden
    #
    #   API Success Response with Form Errors:
    #
    #     STATUS_CODE: 200
    #     {
    #       errors: {
    #         field_1: [
    #           field_1_error_1,
    #           field_1_error_2,
    #           ...
    #         ],
    #         field_2: [
    #           field_2_error_1,
    #           field_2_error_2,
    #           ...
    #         ],
    #         ...
    #       }
    #     }
    class JobsController < ApplicationController
      # Returns job and operation counts.
      #
      # <b>API Call:</b>
      #   GET: /api/v3/jobs/counts
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     counts: {
      #       jobs: {
      #         assigned: <count>,
      #         unassigned: <count>,
      #         finished: <count>
      #       },
      #       operations: {
      #         active: {
      #           <category>: <count>,
      #           ...
      #         },
      #         inactive: [
      #            <category>,
      #            ...
      #         ]
      #       }
      #     }
      #   }
      #
      # @!method counts(token)
      # @param token [String] a token
      def counts
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get counts by job status
        jobs = Job.counts_by_job_status

        # Get counts by operation type
        operations = Job.counts_by_operation_type

        render json: {counts: {jobs: jobs, operations: operations}}.to_json, status: :ok
      end

      # Returns unassigned jobs that have operations
      #
      # <b>API Call:</b>
      #   GET: /api/v3/jobs/unassigned
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     jobs: [
      #       {
      #         id: <id>
      #         created_at: <created_at>
      #         updated_at: <updated_at>
      #         pc: <pc>
      #         job_id: <job_id>
      #         operation_type_id: <operation_type_id>
      #         name: <name>
      #         category: <category>
      #         deployed: <deployed>
      #         operations_count: <operations_count>
      #       },
      #       ...
      #     ]
      #   }
      #
      # @!method unassigned(token)
      # @param token [String] a token
      def unassigned
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # get unassigned jobs
        unassigned = Job.unassigned_jobs

        render json: {jobs: unassigned}.to_json, status: :ok
      end

      # Returns assigned jobs that have operations
      #
      # <b>API Call:</b>
      #   GET: /api/v3/jobs/assigned
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     jobs: [
      #       {
      #         id: <id>
      #         created_at: <created_at>
      #         updated_at: <updated_at>
      #         pc: <pc>
      #         to_name: <to_name>
      #         to_login: <to_login>
      #         job_id: <job_id>
      #         operation_type_id: <operation_type_id>
      #         name: <name>
      #         category: <category>
      #         deployed: <deployed>
      #         operations_count: <operations_count>
      #       },
      #       ...
      #     ]
      #   }
      #
      # @!method assigned(token)
      # @param token [String] a token
      def assigned
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # get assigned jobs
        assigned = Job.assigned_jobs

        render json: {jobs: assigned}.to_json, status: :ok
      end

      # Returns finished jobs that have operations
      #
      # <b>API Call:</b>
      #   GET: /api/v3/jobs/finished
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     jobs: [
      #       {
      #         id: <id>
      #         created_at: <created_at>
      #         updated_at: <updated_at>
      #         pc: <pc>
      #         to_name: <to_name>
      #         to_login: <to_login>
      #         assigned_date: <assigned_date>
      #         job_id: <job_id>
      #         operation_type_id: <operation_type_id>
      #         name: <name>
      #         category: <category>
      #         deployed: <deployed>
      #         operations_count: <operations_count>
      #       },
      #       ...
      #     ]
      #   }
      #
      # @!method finished(token)
      # @param token [String] a token
      def finished
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # get seven_days flag
        seven_days = Input.boolean(params[:seven_days])

        # get assigned jobs
        finished = Job.finished_jobs(seven_days)

        render json: {jobs: finished}.to_json, status: :ok
      end

      # Returns operations for a job id
      #
      # <b>API Call:</b>
      #   GET: /api/v3/jobs/<id>/show
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     operations: [
      #       {
      #         id: <___>,
      #         operation_id: <___>,
      #         updated_at: <___>,
      #         status: <___>,
      #         plan_id: <___>,
      #         inputs: [
      #           {
      #             id: <___>,
      #             name: <___>,
      #             role: "input",
      #             sample_id: <___>,
      #             sample_name: <___>,
      #             object_type_name: <___>
      #           },
      #           ...
      #         ],
      #         outputs: [
      #           {
      #             id: <___>,
      #             name: <___>,
      #             role: "output",
      #             sample_id: <___>,
      #             sample_name: <___>,
      #             object_type_name: <___>
      #           },
      #           ...
      #           ...
      #         ],
      #         data_associations: [
      #           {
      #             id: 945574,
      #             object: { <key>: <value> }
      #           },
      #           ...
      #         ]
      #       },
      #       ...
      #     ]
      #   }
      #
      # @!method show(id, token)
      # @param id [Int] the id of the job
      # @param token [String] a token
      def show
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        ### >>>>>>
        ### TODO: MOVE TO MODEL
        id = params[:id].to_i

        # get list of <plan_id, updated_at, user.name, operation_id, status> for each job
        # multiple operations per job
        # one plan per operation
        # one user per operation
        # order by operation.upated_at desc, operation.id desc
        sql = "
          select ja.id, ja.operation_id, o.updated_at, o.status, pa.plan_id, u.name
          from jobs j
          inner join job_associations ja on ja.job_id = j.id
          inner join operations o on o.id = ja.operation_id
          inner join plan_associations pa on pa.operation_id = o.id
          inner join users u on u.id = o.user_id
          where j.id = #{id}
          order by o.updated_at desc, o.id desc
        "
        job_operations = JobAssociation.find_by_sql sql

        operations = []
        job_operations.each do |jo|
          operation_id = jo.operation_id

          sql = "
            select fv.id, fv.role, fv.name, s.id as 'sample_id', s.name as 'sample_name', ot.name as 'object_type_name'
            from field_values fv
            left join samples s on s.id = fv.child_sample_id
            left join items i on i.id = fv.child_item_id
            left join object_types ot on ot.id = i.object_type_id
            where parent_class = 'Operation' and parent_id = #{operation_id}
            order by fv.role = 'input', fv.name, fv.id
          "
          outputs_inputs = FieldValue.find_by_sql sql

          outputs = []
          inputs = []
          outputs_inputs.each do |oi|
            oi.role == 'input' ? inputs << oi : outputs << oi
          end

          sql = "
            select id, object
            from data_associations
            where parent_class = 'Operation' and parent_id = #{operation_id}
            order by updated_at desc, id desc
          "
          data_associations = DataAssociation.find_by_sql sql

          operations << {id: jo.id, operation_id: jo.operation_id, updated_at: jo.updated_at, status: jo.status, plan_id: jo.plan_id, inputs: inputs, outputs: outputs, data_associations: data_associations}
        end
        ### TODO: MOVE TO MODEL
        ### <<<<<<

        render json: {operations: operations}, status: :ok
      end

      def assign
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get job
        @id = Input.int(params[:id])
        job = Job.find_by(id: @id)
        render json: { error: "Job not found" }.to_json, status: :not_found and return if !job

        @by = response[:user]['id'].to_i
        @to = params[:to_id].to_i

        # Create assignment
        new_job_assignment_log
      end

      def unassign
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get job
        @id = Input.int(params[:id])
        job = Job.find_by(id: @id)
        render json: { error: "Job not found" }.to_json, status: :not_found and return if !job

        @by = response[:user]['id'].to_i
        @to = nil

        # Create assignment
        new_job_assignment_log
      end

      def create
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        ### >>>>>>
        ### TODO: MOVE TO MODEL

        # Get operations that are 'pending'
        operation_ids = [0]
        params[:operation_ids].each do |operation_id|
          operation_ids << operation_id
        end

        # Get pending operations
        sql = "select id, operation_type_id from operations where id in ( #{operation_ids.join(',')} ) and status = 'pending'"
        operations = Operation.find_by_sql sql
        render json: { error: "No pending operations selected" }.to_json, status: :unauthorized and return if operations.length == 0

        # Check that operation_type_ids are the sasme
        sql = "select distinct operation_type_id from operations where id in ( #{operation_ids.join(',')} ) and status = 'pending'"
        distinct = Operation.find_by_sql sql
        render json: { error: "Cannot combine operations with different operation types" }.to_json, status: :unauthorized and return if distinct.length > 1

        timenow = Time.now.utc
        state = [
          {
            'operation' => 'initialize',
            'arguments' => {
              'operation_type_id' => operations[0].operation_type_id,
              'time' => timenow
            }
          }
        ]

        # create the job
        job_new = Job.new
        job_new.user_id = response[:user]['id'].to_i
        job_new.path = 'operation.rb'
        job_new.pc = -1
        job_new.state = state.to_json
        job_new.group_id = nil # this was technicians
        job_new.submitted_by = response[:user]['id'].to_i
        job_new.desired_start_time = timenow
        job_new.latest_start_time = timenow + 1.hour
        job_new.created_at = timenow
        job_new.updated_at = timenow
        job_new.save

        # create the job associations
        pending_ids = []
        operations.each do |operation|
          pending_ids << operation.id

          job_assocation_new = JobAssociation.new
          job_assocation_new.job_id = job_new.id
          job_assocation_new.operation_id = operation.id
          job_assocation_new.save
        end

        # update the operation statuses
        sql = "update operations set status = 'scheduled' where id in ( #{pending_ids.join(',')} )"
        Operation.connection.execute sql

        render json: { job: job_new }.to_json, status: :ok
        ### TODO: MOVE TO MODEL
        ### <<<<<<


      end

      def delete
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get job
        id = Input.int(params[:id])
        job = Job.find_by(id: id)
        render json: { error: "Job not found" }.to_json, status: :not_found and return if !job

        # Delete job
        render json: { error: "Job must be not started" }.to_json, status: :unauthorized and return if job.pc != -1

        # reset operations to 'pending'
        sql = "update operations set status = 'pending' where id in ( select operation_id from job_associations where job_id = #{job.id} )"
        Operation.connection.execute sql

        # delete job (will automatically delete job_associations using foreign keys)
        job.delete
        render json: { message: "Job deleted" }.to_json, status: :ok
      end

      # get 'api/v3/jobs/category/:category'
      def category
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # get status, default to 'pending'
        status = case params[:status]
        when 'error'
          'error'
        when 'waiting'
          'waiting'
        when 'deferred'
          'deferred'
        when 'delayed'
          'delayed'
        else
          'pending'
        end

        category = Input.text(params[:category]) || ''

        # Get operation_types
        sql = "
          select ot.name, count(*) as 'n'
          from operation_types ot
          inner join operations o on o.operation_type_id = ot.id
          where ot.category = ? and o.status = ?
          group by ot.name
          order by ot.name
        "
        operation_types = OperationType.find_by_sql [sql, category, status]

        return if !operation_types[0]

        # Get operations for first operation_type = operation_typs[0].name
        sql = "
          select o.id, pa.plan_id, u.name, o.status, o.updated_at
          from operation_types ot
          inner join operations o on o.operation_type_id = ot.id
          inner join plan_associations pa on pa.operation_id = o.id
          inner join users u on u.id = o.user_id
          where ot.name = ? and o.status = ?
          order by o.updated_at desc
        "
        operations = Operation.find_by_sql [sql, operation_types[0].name, status]

        render json: { operation_types: operation_types, operations: operations }.to_json, status: :ok
      end

      # get 'api/v3/jobs/category/:category/:operation_type'
      def operation_type
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # get status, default to 'pending'
        status = case params[:status]
        when 'error'
          'error'
        when 'waiting'
          'waiting'
        when 'deferred'
          'deferred'
        when 'delayed'
          'delayed'
        else
          'pending'
        end

        category = Input.text(params[:category]) || ''

        operation_type = Input.text(params[:operation_type]) || ''

        # Get operations for first operation_type = operation_typs[0].name
        sql = "
          select o.id, pa.plan_id, u.name, o.status, o.updated_at
          from operation_types ot
          inner join operations o on o.operation_type_id = ot.id
          inner join plan_associations pa on pa.operation_id = o.id
          inner join users u on u.id = o.user_id
          where ot.name = ? and o.status = ?
          order by o.updated_at desc
        "
        operations = Operation.find_by_sql [sql, operation_type, status]

        render json: { operations: operations }.to_json, status: :ok
      end

      # post 'api/v3/jobs/:id/remove/:operation_id'
      def remove

      end

      private

      def new_job_assignment_log
        jal = JobAssignmentLog.new
        jal.job_id = @id
        jal.assigned_by = @by
        jal.assigned_to = @to

        render json: { errors: jal.errors }, status: :unauthorized and return unless jal.valid?

        jal.save!

        render json: { job_assignment_log: jal}, status: :ok
      end
    end
  end
end


