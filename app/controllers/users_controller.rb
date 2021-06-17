class UsersController < ApplicationController
  before_action :logged_in_user, only: [:show, :index, :edit, :update, :following, :followers, :destroy, :wanted_posts]
  before_action :activated_user, only: [:show, :index, :edit, :update, :following, :followers, :wanted_posts]
  before_action :correct_user, only: [:edit, :update, :following, :followers, :wanted_posts]
  before_action :not_logged_in, only: [:new, :create]
  before_action :can_delete_user, only: :destroy

  def show
    @user = User.find_by(id: params[:id])
    if @user && @user.activated?
      @microposts = @user.microposts.order(created_at: "DESC").page(params[:page]).per(5)
    elsif (@user && !@user.activated) || @user.nil?
      flash[:danger] = "ユーザーが見つかりません。"
      redirect_to root_url
    end
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
      @user.send_activation_email
      log_in @user
      flash[:info] = "アカウント認証用のメールを送信しました。メールをご確認ください。"
      redirect_to root_url
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

  def wanted_posts
    @microposts = current_user.wanted_posts.order(created_at: "DESC").page(params[:page]).per(5) if logged_in?
  end

  def resend_activation_email
    @user = current_user
    @user.create_activation_digest
    if @user.update(activation_digest: @user.activation_digest)
      @user.send_activation_email
      flash[:success] = "認証メールが送信されました。"
      redirect_to root_url
    else
      flash[:danger] = "エラーが起きました。もう一度試してください。"
    end
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
