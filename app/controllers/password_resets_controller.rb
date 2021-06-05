class PasswordResetsController < ApplicationController
  before_action :get_user, only:[:edit, :update]
  before_action :valid_user, only:[:edit, :update]
  before_action :check_expiration, only:[:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "メールが送信されました。ご確認ください。"
      redirect_to new_password_reset_url
    else
      flash.now[:login] = "入力されたメールアドレスが見つかりません。"
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update(user_params)
      log_in @user
      @user.update_attribute(:reset_digest,nil)
      flash[:success] = "パスワードの再設定が完了しました。"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # beforeフィルタ
    def get_user
      @user = User.find_by(email: params[:email])
    end

    def valid_user
      unless @user && @user.authenticated?(:reset, params[:id])
        flash[:danger] = "エラーが起きました。"
        redirect_to root_url
      end
    end

    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "有効期限が切れています。"
        redirect_to new_password_reset_url
      end
    end
end
