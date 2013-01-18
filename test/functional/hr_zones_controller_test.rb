require 'test_helper'

class HrZonesControllerTest < ActionController::TestCase
  setup do
    @hr_zone = hr_zones(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:hr_zones)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create hr_zone" do
    assert_difference('HrZone.count') do
      post :create, hr_zone: { enabled: @hr_zone.enabled, user_id: @hr_zone.user_id, z0: @hr_zone.z0, z1: @hr_zone.z1, z2: @hr_zone.z2, z3: @hr_zone.z3, z4: @hr_zone.z4, z5: @hr_zone.z5, z6: @hr_zone.z6, z7: @hr_zone.z7 }
    end

    assert_redirected_to hr_zone_path(assigns(:hr_zone))
  end

  test "should show hr_zone" do
    get :show, id: @hr_zone
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @hr_zone
    assert_response :success
  end

  test "should update hr_zone" do
    put :update, id: @hr_zone, hr_zone: { enabled: @hr_zone.enabled, user_id: @hr_zone.user_id, z0: @hr_zone.z0, z1: @hr_zone.z1, z2: @hr_zone.z2, z3: @hr_zone.z3, z4: @hr_zone.z4, z5: @hr_zone.z5, z6: @hr_zone.z6, z7: @hr_zone.z7 }
    assert_redirected_to hr_zone_path(assigns(:hr_zone))
  end

  test "should destroy hr_zone" do
    assert_difference('HrZone.count', -1) do
      delete :destroy, id: @hr_zone
    end

    assert_redirected_to hr_zones_path
  end
end
