require "test_helper"

class ManageResourcesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_resources_index_url
    assert_response :success
  end
end
