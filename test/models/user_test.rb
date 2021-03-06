require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(handle: "Example User", email: "user@example.com",
      password: "foobar", password_confirmation: "foobar")
  end

  test "associated microposts should be destroyed" do
    @user.save 
    @user.microposts.create!( shop_name: "a",
                              menu_name: "a",
                              content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
  end
end
