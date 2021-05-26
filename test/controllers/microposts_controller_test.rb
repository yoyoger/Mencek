require "test_helper"

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @micropost = microposts(:musashiya)
  end

  test "should redirect post when not logged in" do
    assert_no_difference 'Micropost.count' do
      post postit_path,params: {micropost: {user_id:"1",
                                            shop_name:"a",
                                            menu_name:"a",
                                            content:"aaa"}}
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete delete_post_path(@micropost)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy for wrong post" do
    log_in_as(users(:lana))
    micropost = microposts(:kurenai)
    assert_no_difference 'Micropost.count' do
      delete delete_post_path(micropost)
    end
    assert_redirected_to root_url
  end

  test "should not redirect destroy for any posts" do
    log_in_as(users(:michael))
    micropost = microposts(:kurenai)
    assert_difference 'Micropost.count', -1 do
      delete delete_post_path(micropost)
    end
  end

end
