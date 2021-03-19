class Api::V1::PasswordResetsController < ApplicationController
  before_action :authenticate_user, except: [:create]

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user&.activated
      @user.send_email_for(:password_reset)
      payload = {
        type: 'info',
        msg: 'パスワード再設定メールを送信しました。30分以内に再設定を完了してください'
      }
    elsif @user && !@user.activated
      payload = {
        type: 'error',
        msg: 'メールアドレスを認証してください'
      }
    else
      payload = { type: 'error', msg: 'メールアドレスが見つかりませんでした' }
    end
    render json: payload
  end

  def update
    @user = current_user
    if user_params[:password].empty?
      @user.errors.add(:password, :blank)
      payload = {
        type: 'error',
        msg: @user.errors.full_messages
      }
    elsif @user.update(user_params)
      cookies[token_access_key] = cookie_token
      payload = {
        type: 'success',
        msg: 'パスワードの再設定が完了しました',
        user: @user.my_json,
        exp: _auth.payload[:exp]
      }
    else
      payload = { type: 'error', msg: 'パスワード再設定に失敗しました。もう一度操作をやり直してください' }
    end
    render json: payload
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def _auth
    @_auth ||= UserAuth::AuthToken.new(payload: { sub: current_user.id })
  end

  def cookie_token
    {
      value: _auth.token,
      expires: Time.zone.at(_auth.payload[:exp]),
      secure: Rails.env.production?,
      http_only: true
    }
  end
end
