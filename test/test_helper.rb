ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require "rails/test_help"
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper



  #テストユーザーとしてログインする
  def log_in_as(user)
    session[:user_id] = user.id
  end

  #テストユーザーがログイン中の場合にtrueを返す
  def is_logged_in?
    !session[:user_id].nil?
  end

end

class ActionDispatch::IntegrationTest

  #テストユーザーとしてログインする
  def log_in_as(user,password:'password')
    post login_path,params: { session: { email: user.email,
                                         password: password  } }
  end

  #テストユーザーがログイン中の場合にtrueを返す
  def is_logged_in?
    !session[:user_id].nil?
  end
end
