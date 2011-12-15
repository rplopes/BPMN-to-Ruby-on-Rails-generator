require 'test_helper'

class OfficesControllerTest < ActionController::TestCase
  setup do
    @office = offices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:offices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create office" do
    assert_difference('Office.count') do
      post :create, :office => @office.attributes
    end

    assert_redirected_to office_path(assigns(:office))
  end

  test "should show office" do
    get :show, :id => @office.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @office.to_param
    assert_response :success
  end

  test "should update office" do
    put :update, :id => @office.to_param, :office => @office.attributes
    assert_redirected_to office_path(assigns(:office))
  end

  test "should destroy office" do
    assert_difference('Office.count', -1) do
      delete :destroy, :id => @office.to_param
    end

    assert_redirected_to offices_path
  end
end
