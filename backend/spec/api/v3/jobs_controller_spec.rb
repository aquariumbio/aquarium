require 'rails_helper'

RSpec.describe Api::V3::JobsController, type: :request do
  describe 'api' do
    # Sign in users
    before :all do
      @create_url = "/api/v3/token/create"
      @token_1 = []

      post "#{@create_url}?login=user_admin&password=aquarium123"
      response_body = JSON.parse(response.body)
      @token_1 << response_body["token"]

      @job_id = []
    end

    # Get counts
    it "get_counts" do
      get "/api/v3/jobs/counts?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      expect(response_body["counts"]["jobs"]["assigned"]).to eq 0
    end

    # Get unassigned
    it "get_unassigned" do
      get "/api/v3/jobs/unassigned?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      expect(response_body["jobs"].length).to eq 0
    end

    # Get assigned
    it "get_assigned" do
      get "/api/v3/jobs/assigned?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      expect(response_body["jobs"].length).to eq 0
    end

    # Get finished
    it "get_finished" do
      get "/api/v3/jobs/finished?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      expect(response_body["jobs"].length).to eq 0
    end

    # Dummy tests to replace with real tests later
    it "dummy_tests" do
      # Insert dummy data into database.
      # Easier to use direct SQL Query exported from development_database instead of ActiveRecord because this is just temporary for the tests
      sql = "
        INSERT INTO `users` (`id`, `name`, `login`, `created_at`, `updated_at`, `password_digest`, `remember_token`, `admin`, `key`, `permission_ids`)
        VALUES
          (93, 'Cami Cordray', 'cpc3', '2015-03-19 16:09:43', '2015-03-19 16:09:43', '$2a$10$JKJzJDROI7DlKVKxTctWGuQO9RxZ6dWP3M09p0/oHnYbOnPfUByZu', '6EIV6pGUQTR_epc8_u4GjA', 0, NULL, '.');
      "
      User.connection.execute sql

      sql = "
        INSERT INTO `operation_types` (`id`, `name`, `category`, `deployed`, `on_the_fly`, `created_at`, `updated_at`)
        VALUES
          (361, 'Innoculate Yeast Library', 'Yeast Display', 1, NULL, '2017-12-18 20:23:17', '2017-12-19 00:01:48');
      "
      OperationType.connection.execute sql

      sql = "
        INSERT INTO `operations` (`id`, `operation_type_id`, `status`, `user_id`, `created_at`, `updated_at`, `x`, `y`, `parent_id`)
        VALUES
          (293179, 361, 'pending', 93, '2021-03-01 22:21:49', '2021-03-03 18:03:49', 592, 232, 0),
          (293178, 361, 'pending', 93, '2021-03-01 22:21:49', '2021-03-03 18:03:48', 416, 232, 0);
        ;
      "
      Operation.connection.execute sql

      sql = "delete from budgets"
      Budget.connection.execute sql
      sql = "
        INSERT INTO `budgets` (`id`, `name`, `overhead`, `contact`, `created_at`, `updated_at`, `description`, `email`, `phone`)
        VALUES
          (1, 'BIOFAB', NULL, 'Cami Cordray', '2016-04-05 15:27:02', '2017-11-13 23:54:55', 'Work related directly to the BIOFAB', 'cpc3@uw.edu', '(206)221-0941');
      "
      Budget.connection.execute sql

      sql = "
        INSERT INTO `plans` (`id`, `user_id`, `created_at`, `updated_at`, `budget_id`, `name`, `status`, `cost_limit`, `folder`, `layout`)
        VALUES
          (40394, 93, '2021-03-01 22:19:19', '2021-03-03 17:52:34', 1, 'Challenge and Label test', NULL, NULL, NULL, '{\"id\":0,\"parent_id\":-1,\"name\":\"Untitled Module 0\",\"x\":160,\"y\":160,\"width\":160,\"height\":60,\"model\":{\"model\":\"Module\"},\"input\":null,\"output\":null,\"documentation\":\"No documentation yet for this module.\",\"children\":null,\"wires\":null,\"text_boxes\":[{\"x\":832,\"y\":48,\"anchor\":{\"x\":200,\"y\":100},\"markdown\":\"**{\\\"od_ml_needed\\\": 0.83, \\\"assay_microliters\\\": 50,\\\"protease_dilution_factor\\\": 1.0, \\\"protease_working_microliters\\\": 50, \\\"protease_incubation_time_minutes\\\": 45,  \\\"n_protease_washes\\\": 1, \\\"quench_protease\\\": false} \\n{\\\"od_ml_needed\\\": 0.83, \\\"assay_microliters\\\": 50,\\\"protease_dilution_factor\\\": 1.0, \\\"protease_working_microliters\\\": 50, \\\"protease_incubation_time_minutes\\\": 40,  \\\"n_protease_washes\\\": 1, \\\"quench_protease\\\": false}**.\"}]}');
      "
      Plan.connection.execute sql

      sql = "
        INSERT INTO `plan_associations` (`id`, `plan_id`, `operation_id`, `created_at`, `updated_at`)
        VALUES
          (278623, 40394, 293178, '2021-03-01 22:21:49', '2021-03-01 22:21:49'),
          (278624, 40394, 293179, '2021-03-01 22:21:49', '2021-03-01 22:21:49');
      "
      PlanAssociation.connection.execute sql

      ### create job
      post "/api/v3/jobs/create?token=#{@token_1[0]}&operation_ids[]=293178&operation_ids[]=293179"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      @job_id << response_body["job"]["id"]
      expect(response_body["job"]["user_id"]).to eq 1

      ### show job
      get "/api/v3/jobs/#{@job_id[0]}/show?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      expect(response_body["operations"].length).to eq 2

      ### assign job
      post "/api/v3/jobs/#{@job_id[0]}/assign?token=#{@token_1[0]}&to_id=2"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      expect(response_body["job_assignment_log"]["assigned_to"]).to eq 2

      ### unassign job
      post "/api/v3/jobs/#{@job_id[0]}/unassign?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      expect(response_body["job_assignment_log"]["assigned_to"]).to eq nil

      ### remove operation
      post "/api/v3/jobs/#{@job_id[0]}/remove/293178?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      expect(response_body["message"]).to eq "Operation removed"

      ### delete job
      post "/api/v3/jobs/#{@job_id[0]}/delete?token=#{@token_1[0]}"
      expect(response).to have_http_status 200

      # response
      response_body = JSON.parse(response.body)
      expect(response_body["message"]).to eq "Job deleted"
    end
  end
end
