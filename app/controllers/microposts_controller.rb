class MicropostsController < ApplicationController
  before_action :logged_in_user
  before_action :can_delete_user, only: :destroy


  def show
    @micropost = Micropost.find(params[:id])
    @user = @micropost.user
  end

  def new
    @micropost = current_user.microposts.build
  end

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "正常に投稿が完了しました。"
      redirect_to post_path(@micropost)
    else
      render 'new'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "削除しました。"
    redirect_to request.referrer || root_url
  end

  private
    def micropost_params
      params.require(:micropost).permit(:shop_name,:menu_name,:content)
    end

    def can_delete_user
      @micropost = Micropost.find_by(id: params[:id])
      redirect_to(root_url) unless ( current_user.admin? || current_user?(@micropost.user) )
    end
end
