class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user, except: [:create]

  def create
    @user = User.new(signup_params)
    if @user.save
      @user.send_email_for(:account_activation)
      type = 'info'
      msg = '認証メールを送信しました。' \
            '２時間以内にメール認証を完了してください'
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
    params.require(:user).permit(:name, :user_name, :email, :password)
  end
end
