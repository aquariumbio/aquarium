require 'test_helper'

class WizardsControllerTest < ActionController::TestCase
  setup do
    @wizard = wizards(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:wizards)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create wizard' do
    assert_difference('Wizard.count') do
      post :create, wizard: { name: @wizard.name, specification: @wizard.specification }
    end

    assert_redirected_to wizard_path(assigns(:wizard))
  end

  test 'should show wizard' do
    get :show, id: @wizard
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @wizard
    assert_response :success
  end

  test 'should update wizard' do
    put :update, id: @wizard, wizard: { name: @wizard.name, specification: @wizard.specification }
    assert_redirected_to wizard_path(assigns(:wizard))
  end

  test 'should destroy wizard' do
    assert_difference('Wizard.count', -1) do
      delete :destroy, id: @wizard
    end

    assert_redirected_to wizards_path
  end
end
