require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user       = users(:michael)
    @second_user = users(:archer)
    @third_user  = users(:lana)
  end

  test "should redrect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@third_user)
    end
    assert_redirected_to login_url
  end


  test "should redirect destroy when logged in as a non-current_user & non-admin" do
    log_in_as(@second_user)
    assert_no_difference 'User.count' do
      delete user_path(@third_user)
    end
    assert_redirected_to root_url
    assert_not flash.nil?
  end

  test "should destroy any other users when logged in as admin " do
    log_in_as(@user)
    get user_path(@third_user)
    assert_difference 'User.count', -1 do
      delete user_path(@third_user)
    end
    assert_redirected_to user_index_url
    assert_not flash.nil?
  end

end
