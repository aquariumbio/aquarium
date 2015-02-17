require 'test_helper'

class PostAssociationsControllerTest < ActionController::TestCase
  setup do
    @post_association = post_associations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:post_associations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create post_association" do
    assert_difference('PostAssociation.count') do
      post :create, post_association: { item_id: @post_association.item_id, job_id: @post_association.job_id, post_id: @post_association.post_id, sample_id: @post_association.sample_id, task_id: @post_association.task_id }
    end

    assert_redirected_to post_association_path(assigns(:post_association))
  end

  test "should show post_association" do
    get :show, id: @post_association
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @post_association
    assert_response :success
  end

  test "should update post_association" do
    put :update, id: @post_association, post_association: { item_id: @post_association.item_id, job_id: @post_association.job_id, post_id: @post_association.post_id, sample_id: @post_association.sample_id, task_id: @post_association.task_id }
    assert_redirected_to post_association_path(assigns(:post_association))
  end

  test "should destroy post_association" do
    assert_difference('PostAssociation.count', -1) do
      delete :destroy, id: @post_association
    end

    assert_redirected_to post_associations_path
  end
end
