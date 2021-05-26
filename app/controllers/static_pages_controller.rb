class StaticPagesController < ApplicationController
  def home
    @user = current_user
    @feed_items = @user.feed.page(params[:page]).per(5) if logged_in?
  end
end
