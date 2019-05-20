require 'test_helper'

class InterpreterControllerTest < ActionController::TestCase
  test 'should get arguments' do
    get :arguments
    assert_response :success
  end

  test 'should get submit' do
    get :submit
    assert_response :success
  end

  test 'should get next' do
    get :next
    assert_response :success
  end

  test 'should get abort' do
    get :abort
    assert_response :success
  end
end
