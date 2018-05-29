# frozen_string_literal: true

require 'test_helper'

class LogsControllerTest < ActionController::TestCase
  setup do
    @log = logs(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:logs)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create log' do
    assert_difference('Log.count') do
      post :create, log: { data: @log.data, job: @log.job, protcol_name: @log.protcol_name, protocol_sha: @log.protocol_sha, type: @log.type, user: @log.user }
    end

    assert_redirected_to log_path(assigns(:log))
  end

  test 'should show log' do
    get :show, id: @log
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @log
    assert_response :success
  end

  test 'should update log' do
    put :update, id: @log, log: { data: @log.data, job: @log.job, protcol_name: @log.protcol_name, protocol_sha: @log.protocol_sha, type: @log.type, user: @log.user }
    assert_redirected_to log_path(assigns(:log))
  end

  test 'should destroy log' do
    assert_difference('Log.count', -1) do
      delete :destroy, id: @log
    end

    assert_redirected_to logs_path
  end
end
