require 'test_helper'

class LiasonControllerTest < ActionController::TestCase
  test 'should get get' do
    get :get
    assert_response :success
  end

  test 'should get put' do
    get :put
    assert_response :success
  end

  test 'should get adjust' do
    get :adjust
    assert_response :success
  end

end
