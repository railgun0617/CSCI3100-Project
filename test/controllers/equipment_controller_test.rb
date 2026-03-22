require "test_helper"

class EquipmentControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get equipment_index_url
    assert_response :success
  end

  test "should get show" do
    get equipment_show_url
    assert_response :success
  end

  test "should get new" do
    get equipment_new_url
    assert_response :success
  end

  test "should get edit" do
    get equipment_edit_url
    assert_response :success
  end
end
