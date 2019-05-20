require 'test_helper'

class OperationControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get create' do
    get :create
    assert_response :success
  end

  test 'should get update' do
    get :update
    assert_response :success
  end

  test 'should get destroy' do
    get :destroy
    assert_response :success
  end

end
