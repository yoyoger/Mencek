class UsersController < ApplicationController
  before_action :logged_in_user, only: [:show, :index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :not_logged_in, only: [:new, :create]
  before_action :can_delete_user, only: :destroy

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.page(params[:page]).per(5)
  end

  def index
    @users = User.where.not(id: current_user.id).page(params[:page])
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
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "プロフィールを更新しました。"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:danger]= "ユーザーを削除しました。"
    redirect_to user_index_url
  end

  private

    def user_params
      params.require(:user).permit(:handle, :email, :password, :password_confirmation)
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
