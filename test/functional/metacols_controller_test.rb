

require 'test_helper'

class MetacolsControllerTest < ActionController::TestCase
  setup do
    @metacol = metacols(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:metacols)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create metacol' do
    assert_difference('Metacol.count') do
      post :create, metacol: { path: @metacol.path, sha: @metacol.sha, state: @metacol.state, status: @metacol.status, user_id: @metacol.user_id }
    end

    assert_redirected_to metacol_path(assigns(:metacol))
  end

  test 'should show metacol' do
    get :show, id: @metacol
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @metacol
    assert_response :success
  end

  test 'should update metacol' do
    put :update, id: @metacol, metacol: { path: @metacol.path, sha: @metacol.sha, state: @metacol.state, status: @metacol.status, user_id: @metacol.user_id }
    assert_redirected_to metacol_path(assigns(:metacol))
  end

  test 'should destroy metacol' do
    assert_difference('Metacol.count', -1) do
      delete :destroy, id: @metacol
    end

    assert_redirected_to metacols_path
  end
end
