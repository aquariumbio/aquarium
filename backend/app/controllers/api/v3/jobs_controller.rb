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
      # @!method counts(token)
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
      # @!method counts(token)
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
      # @!method counts(token)
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

      def show
        # get job details = plan + input / output + udpated + client + op id + status

      end

      def assign

      end

      def unassign

      end

      def delete

      end

      def operations
        # show assigned to + started + finished + protocol + job id + operations count

      end
    end
  end
end
