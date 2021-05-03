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
    class JobAssignmentsController < ApplicationController
      # Assigns a job to a user
      #
      # <b>API Call:</b>
      #   GET: /api/v3/jobs/<id>/assign
      #   {
      #     token: <token>
      #     to_id: <to_id>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     job_assignment_log: {
      #       id: <id>,
      #       job_id: <job_id>,
      #       assigned_by: <assigned_by>,
      #       assigned_to: <assigned_to>,
      #       created_at: <created_at>,
      #       updated_at: <updated_at>
      #     }
      #   }
      #
      # @!method assign(id, token, to_id)
      # @param id [Int] the id of the job
      # @param token [String] a token
      # @param to_id [Int] the id of the assigned_to user
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

      # Unassigns a job
      #
      # <b>API Call:</b>
      #   GET: /api/v3/jobs/<id>/unassign
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     job_assignment_log: {
      #       id: <id>,
      #       job_id: <job_id>,
      #       assigned_by: <assigned_by>,
      #       assigned_to: null,
      #       created_at: <created_at>,
      #       updated_at: <updated_at>
      #     }
      #   }
      #
      # @!method unassign(id, token)
      # @param id [Int] the id of the job
      # @param token [String] a token
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

      private

      def new_job_assignment_log
        jal = JobAssignmentLog.new
        jal.job_id = @id
        jal.assigned_by = @by
        jal.assigned_to = @to

        render json: { errors: jal.errors }, status: :unauthorized and return unless jal.valid?

        jal.save!

        render json: { job_assignment_log: jal }, status: :ok
      end
    end
  end
end
