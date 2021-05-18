class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def index
    #set up after log in
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "アカウントの作成に成功しました。"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

    def user_params
      params.require(:user).permit(:handle, :email, :password, :password_confirmation)
    end

end
