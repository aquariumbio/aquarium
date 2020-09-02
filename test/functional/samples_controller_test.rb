# typed: false
# frozen_string_literal: true

require 'test_helper'

class SamplesControllerTest < ActionController::TestCase
  setup do
    @sample = samples(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:samples)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create sample' do
    assert_difference('Sample.count') do
      post :create, sample: { field1: @sample.field1, field2: @sample.field2, field3: @sample.field3, field4: @sample.field4, name: @sample.name, owner: @sample.owner, project: @sample.project, sample_type_id: @sample.sample_type_id }
    end

    assert_redirected_to sample_path(assigns(:sample))
  end

  test 'should show sample' do
    get :show, id: @sample
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @sample
    assert_response :success
  end

  test 'should update sample' do
    put :update, id: @sample, sample: { field1: @sample.field1, field2: @sample.field2, field3: @sample.field3, field4: @sample.field4, name: @sample.name, owner: @sample.owner, project: @sample.project, sample_type_id: @sample.sample_type_id }
    assert_redirected_to sample_path(assigns(:sample))
  end

  test 'should destroy sample' do
    assert_difference('Sample.count', -1) do
      delete :destroy, id: @sample
    end

    assert_redirected_to samples_path
  end
end
