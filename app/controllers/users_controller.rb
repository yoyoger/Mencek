class UsersController < ApplicationController
  before_action :logged_in_user, only: [:show, :index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :following, :followers]
  before_action :not_logged_in, only: [:new, :create]
  before_action :can_delete_user, only: :destroy

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.order(created_at: "DESC").page(params[:page]).per(5)
  end

  def index
    @users = User.where.not("user_id = ?", current_user.id).joins(:microposts).group("users.id").select("users.*, MAX(microposts.created_at) micropost_created_at").order("MAX(microposts.created_at) DESC").page(params[:page]).per(9)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "アカウントの作成に成功しました。"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      ActiveStorage::Blob.unattached.find_each(&:purge)
      flash[:success] = "プロフィールを更新しました。"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).icon.purge
    User.find(params[:id]).destroy
    flash[:danger]= "ユーザーを削除しました。"
    if current_user.admin?
      redirect_to user_index_url
    else
      redirect_to root_url
    end
  end

  def following
    @user = User.find(params[:id])
    @title = "#{@user.handle} さんがフォローしているユーザー"
    @users = @user.following.order("relationships.created_at DESC").page(params[:page]).per(9)
    render 'show_follow'
  end

  def followers
    @user = User.find(params[:id])
    @title = "#{@user.handle} さんのフォロワー"
    @users = @user.followers.order("relationships.created_at DESC").page(params[:page]).per(9)
    render 'show_follow'
  end

  private

    def user_params
      params.require(:user).permit(:icon,:handle, :email, :password, :password_confirmation)
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def not_logged_in
      if logged_in?
        redirect_to root_url
      end
    end

    def can_delete_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless (current_user.admin? || current_user?(@user))
    end
end
