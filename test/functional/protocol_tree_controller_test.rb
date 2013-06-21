require 'test_helper'

class ProtocolTreeControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get subtree" do
    get :subtree
    assert_response :success
  end

  test "should get raw" do
    get :raw
    assert_response :success
  end

end
