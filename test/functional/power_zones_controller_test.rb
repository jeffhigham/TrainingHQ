require 'test_helper'

class PowerZonesControllerTest < ActionController::TestCase
  setup do
    @power_zone = power_zones(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:power_zones)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create power_zone" do
    assert_difference('PowerZone.count') do
      post :create, power_zone: { enabled: @power_zone.enabled, user_id: @power_zone.user_id, z0: @power_zone.z0, z1: @power_zone.z1, z2: @power_zone.z2, z3: @power_zone.z3, z4: @power_zone.z4, z5: @power_zone.z5, z6: @power_zone.z6, z7: @power_zone.z7 }
    end

    assert_redirected_to power_zone_path(assigns(:power_zone))
  end

  test "should show power_zone" do
    get :show, id: @power_zone
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @power_zone
    assert_response :success
  end

  test "should update power_zone" do
    put :update, id: @power_zone, power_zone: { enabled: @power_zone.enabled, user_id: @power_zone.user_id, z0: @power_zone.z0, z1: @power_zone.z1, z2: @power_zone.z2, z3: @power_zone.z3, z4: @power_zone.z4, z5: @power_zone.z5, z6: @power_zone.z6, z7: @power_zone.z7 }
    assert_redirected_to power_zone_path(assigns(:power_zone))
  end

  test "should destroy power_zone" do
    assert_difference('PowerZone.count', -1) do
      delete :destroy, id: @power_zone
    end

    assert_redirected_to power_zones_path
  end
end
