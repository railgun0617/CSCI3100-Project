require "test_helper"

class StaffControllerTest < ActionDispatch::IntegrationTest
  test "should get dashboard" do
    get staff_dashboard_url
    assert_response :success
  end
end
