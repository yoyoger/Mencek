class SessionsController < ApplicationController
  before_action :not_logged_in, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1'? remember(user) : forget(user)
      if !user.activated?
        flash[:danger] = "このアカウントは認証されていません。送信されたメールからアカウントを認証してください。"
      end
      redirect_back_or root_url
    else
      flash.now[:login] = "入力されたメールアドレスまたはパスワードに誤りがあります。"
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private
    def not_logged_in
      if logged_in?
        redirect_to root_url
      end
    end
end
