require 'test_helper'

class TaskPrototypesControllerTest < ActionController::TestCase
  setup do
    @task_prototype = task_prototypes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:task_prototypes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create task_prototype" do
    assert_difference('TaskPrototype.count') do
      post :create, task_prototype: { description: @task_prototype.description, name: @task_prototype.name, prototype: @task_prototype.prototype }
    end

    assert_redirected_to task_prototype_path(assigns(:task_prototype))
  end

  test "should show task_prototype" do
    get :show, id: @task_prototype
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @task_prototype
    assert_response :success
  end

  test "should update task_prototype" do
    put :update, id: @task_prototype, task_prototype: { description: @task_prototype.description, name: @task_prototype.name, prototype: @task_prototype.prototype }
    assert_redirected_to task_prototype_path(assigns(:task_prototype))
  end

  test "should destroy task_prototype" do
    assert_difference('TaskPrototype.count', -1) do
      delete :destroy, id: @task_prototype
    end

    assert_redirected_to task_prototypes_path
  end
end
