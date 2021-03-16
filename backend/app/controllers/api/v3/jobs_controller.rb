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
        # get job details = plan + input / output + udpated + client + op id + status
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

        render json: {operations: operations}
      end

      def assign

      end

      def unassign

      end

      def delete

      end

      def by_operation
        # show assigned to + started + finished + protocol + job id + operations count

      end
    end
  end
end
