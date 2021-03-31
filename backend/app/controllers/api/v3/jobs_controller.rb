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

        render json: { counts: { jobs: jobs, operations: operations } }.to_json, status: :ok
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

        # Get unassigned jobs
        unassigned = Job.unassigned_jobs

        render json: { jobs: unassigned }.to_json, status: :ok
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

        # Get assigned jobs
        assigned = Job.assigned_jobs

        render json: { jobs: assigned }.to_json, status: :ok
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

        # Read seven_days flag
        seven_days = Input.boolean(params[:seven_days])

        # Get assigned jobs
        finished = Job.finished_jobs(seven_days)

        render json: { jobs: finished }.to_json, status: :ok
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

        id = params[:id].to_i

        # get operations in job
        job_operations = JobAssociation.job_operations(id)

        operations = []
        job_operations.each do |jo|
          operation_id = jo.operation_id

          # get outputs and inputs for operation
          outputs, inputs = FieldValue.outputs_inputs(operation_id)

          # get data_associations for operation
          data_associations = DataAssociation.data_associations(operation_id)

          operations << { id: jo.id, operation_id: jo.operation_id, updated_at: jo.updated_at, status: jo.status, plan_id: jo.plan_id, inputs: inputs, outputs: outputs, data_associations: data_associations }
        end

        render json: { operations: operations }, status: :ok
      end

      # Creates a job
      #
      # <b>API Call:</b>
      #   GET: /api/v3/jobs/create
      #   {
      #     token: <token>,
      #     operation_ids[]: <operation_id>,
      #     operation_ids[]: <operation_id>,
      #     ...
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     job: {
      #       id: <___>,
      #       user_id: <___>,
      #       arguments: null,
      #       state: [
      #         {
      #           operation: "initialize",
      #           arguments: {
      #             operation_type_id: <operation_type_id>,
      #             time: <timenow>
      #           }
      #         }
      #       ]
      #       created_at: <created_at>,
      #       updated_at: <updated_at>,
      #       path: "operation.rb",
      #       pc: -1,
      #       group_id: null,
      #       submitted_by: <submitted_by>,
      #       desired_start_time: <timenow>,
      #       latest_start_time: <timenow + 1.hour>,
      #       metacol_id: null,
      #       successor_id: null
      #     }
      #   }
      # @!method create(token, operation_ids[])
      # @param token [String] a token
      # @param operation_ids [Array] the list of operation_ids
      def create
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read operation ids
        operation_ids = [0]
        params[:operation_ids].each do |operation_id|
          operation_ids << operation_id
        end

        # Get pending operations
        operations = Operation.pending_operations(operation_ids)
        render json: { error: "No pending operations selected" }.to_json, status: :unauthorized and return if operations.length == 0

        # Check that operation_type_ids are the same
        distinct = Operation.distinct_operation_types(operation_ids, 'pending')
        render json: { error: "Cannot combine operations with different operation types" }.to_json, status: :unauthorized and return if distinct.length > 1

        # Set the state for the job
        # Set timenow so that the time matches created_at and updated_at for the job
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
        job = Job.create({
                           user_id: response[:user]['id'].to_i,
                           path: 'operation.rb',
                           pc: -1,
                           state: state.to_json,
                           group_id: nil, # this was technicians
                           submitted_by: response[:user]['id'].to_i,
                           desired_start_time: timenow,
                           latest_start_time: timenow + 1.hour,
                           created_at: timenow,
                           updated_at: timenow
                         })

        # create the job associations
        pending_ids = []
        operations.each do |operation|
          pending_ids << operation.id

          job_assocation = JobAssociation.create({
                                                   job_id: job.id,
                                                   operation_id: operation.id
                                                 })
        end

        Operation.set_status_for_ids('scheduled', pending_ids)

        render json: { job: job }.to_json, status: :ok
      end

      # Deletes a job
      #
      # <b>API Call:</b>
      #   GET: /api/v3/jobs/<id>/delete
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     message: "Job deleted"
      #   }
      #
      # @!method delete(id, token)
      # @param id [Int] the id of the job
      # @param token [String] a token
      def delete
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get job
        id = Input.int(params[:id])
        job = Job.find_by(id: id)
        render json: { error: "Job not found" }.to_json, status: :not_found and return if !job

        # Check job status
        render json: { error: "Job must be not started" }.to_json, status: :unauthorized and return if job.pc != -1

        # reset operations to 'pending'
        Operation.set_status_for_job('pending', job.id)

        # delete job (will automatically delete job_associations using foreign keys)
        job.delete
        render json: { message: "Job deleted" }.to_json, status: :ok
      end

      # Returns operation_types for a given category and operations with a given status for the first operation_type
      #
      # <b>API Call:</b>
      #   GET: api/v3/jobs/category/:category
      #   {
      #     token: <token>,
      #     status: <status>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     operation_types: [
      #       {
      #         id: null,
      #         name: <name>,
      #         n: <n>
      #       },
      #       ...
      #     ],
      #     <first_operation_type>: {
      #       operations: [
      #         {
      #           id: <id>,
      #           status: <status>,
      #           updated_at: <updated_at>,
      #           plan_id: <plan_id>,
      #           name: <name>
      #         },
      #         ...
      #       ]
      #     }
      #
      # @!method category(token, category, status)
      # @param token [String] a token
      # @param category [String] category of operations_types
      # @param status [String] status of operations
      def category
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read category
        category = Input.text(params[:category]) || ''

        # Read status, default to 'pending'
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

        # Get operation_types for selected category, status
        operation_types = OperationType.operation_types(category, status)
        render json: { error: "No operation types" }.to_json, status: :not_found and return if !operation_types[0]

        # Get operations for first operation_type = operation_typs[0].name and status
        operations = Operation.operations_for_category_type_status(category, operation_types[0].name, status)

        render json: { operation_types: operation_types, operation_types[0].name => { operations: operations } }.to_json, status: :ok
      end

      # Returns operations with a given status for a given category and a given operation_type
      #
      # <b>API Call:</b>
      #   GET: api/v3/jobs/category/:category/:operation_type
      #   {
      #     token: <token>,
      #     status: <status>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     operations: [
      #       {
      #         id: <id>,
      #         status: <status>,
      #         updated_at: <updated_at>,
      #         plan_id: <plan_id>,
      #         name: <name>
      #       },
      #       ...
      #     ]
      #   }
      #
      # @!method operation_type(token, category, operation_type, status)
      # @param token [String] a token
      # @param category [String] category of operations_types
      # @param operation_type [String] specific operations_type
      # @param status [String] status of operations
      def operation_type
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Read category
        category = Input.text(params[:category]) || ''

        # Read status, default to 'pending'
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

        # Read operation type
        operation_type = Input.text(params[:operation_type]) || ''

        # Get operations for category, type, and status
        operations = Operation.operations_for_category_type_status(category, operation_type, status)

        render json: { operations: operations }.to_json, status: :ok
      end

      # Remove an operation from a job
      #
      # <b>API Call:</b>
      #   GET: /api/v3/jobs/<id>/remove/<operation_id>
      #   {
      #     token: <token>
      #   }
      #
      # <b>API Return Success:</b>
      #   STATUS_CODE: 200
      #   {
      #     message: "Operation removed"
      #   }
      #
      # @!method remove(id, operation_id, token)
      # @param id [Int] the id of the job
      # @param operation_id [Int] the operation_id of the operation
      # @param token [String] a token
      def remove
        # Check for manage permissions
        status, response = check_token_for_permission(Permission.manage_id)
        render json: response.to_json, status: status.to_sym and return if response[:error]

        # Get job
        id = Input.int(params[:id])
        job = Job.find_by(id: id)
        render json: { error: "Job not found" }.to_json, status: :not_found and return if !job

        # Check job status
        render json: { error: "Job must be not started" }.to_json, status: :unauthorized and return if job.pc != -1

        # Get operation (and verify that it is in the job)
        operation_id = Input.int(params[:operation_id])
        operation = Operation.find_by(id: operation_id)
        render json: { error: "Operation not found" }.to_json, status: :not_found and return if !operation

        # Check operation status
        render json: { error: "Operation must be scheduled" }.to_json, status: :unauthorized and return if operation.status != 'scheduled'

        # remove operation from job
        JobAssociation.remove_operation_from_job(operation_id, job.id)

        # update the operation status
        Operation.set_status_for_ids('pending', [operation_id])

        # NOTE: may want to remove the job if there are no operations left in the job

        render json: { message: "Operation removed" }.to_json, status: :ok
      end
    end
  end
end
