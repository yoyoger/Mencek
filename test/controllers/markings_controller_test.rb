require "test_helper"

class MarkingsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get markings_create_url
    assert_response :success
  end

  test "should get destroy" do
    get markings_destroy_url
    assert_response :success
  end
end
