class MicropostsController < ApplicationController
  before_action :logged_in_user
  before_action :activated_user
  before_action :can_delete_user, only: :destroy


  def show
    @micropost = Micropost.find_by(id: params[:id])
    if @micropost
      @user = @micropost.user
    else
      flash[:danger] = "投稿が見つかりません。"
      redirect_to root_url
    end
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
    @user = @micropost.user
    @micropost.pictures.each do |pic|
      pic.purge
    end
    @micropost.destroy
    flash[:success] = "削除しました。"
    redirect_to @user
  end

  private
    def micropost_params
      params.require(:micropost).permit(:shop_name,:menu_name,:content,pictures:[])
    end

    def can_delete_user
      @micropost = Micropost.find_by(id: params[:id])
      redirect_to(root_url) unless ( current_user.admin? || current_user?(@micropost.user) )
    end
end
