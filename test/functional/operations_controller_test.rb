

require 'test_helper'

class OperationsControllerTest < ActionController::TestCase
  setup do
    @operation = operations(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:operations)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create operation' do
    assert_difference('Operation.count') do
      post :create, operation: {}
    end

    assert_redirected_to operation_path(assigns(:operation))
  end

  test 'should show operation' do
    get :show, id: @operation
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @operation
    assert_response :success
  end

  test 'should update operation' do
    put :update, id: @operation, operation: {}
    assert_redirected_to operation_path(assigns(:operation))
  end

  test 'should destroy operation' do
    assert_difference('Operation.count', -1) do
      delete :destroy, id: @operation
    end

    assert_redirected_to operations_path
  end
end
