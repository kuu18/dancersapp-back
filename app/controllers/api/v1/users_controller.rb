class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user, except: [:create]

  def create
    @user = User.new(signup_params)
    if @user.save
      type = 'info'
      msg = '認証メールを送信しました。'
    else
      type = 'error'
      errors = @user.errors.full_messages.join(', ').to_s
    end
    render json: {
      type: type,
      msg: msg,
      errors: errors
    }
  end

  def show
    render json: current_user.my_json
  end

  private

  def signup_params
    params.require(:user).permit(:name, :email, :password)
  end
end
