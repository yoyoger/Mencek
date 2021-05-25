require "test_helper"

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get microposts_new_url
    assert_response :success
  end

  test "should get create" do
    get microposts_create_url
    assert_response :success
  end

  test "should get destroy" do
    get microposts_destroy_url
    assert_response :success
  end
end
