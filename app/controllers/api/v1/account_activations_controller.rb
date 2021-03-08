class Api::V1::AccountActivationsController < ApplicationController
  before_action :authenticate_user
  def index
    @user = current_user
    if @user.activated
      payload = { type: 'error', msg: '無効なURLです' }
    elsif @user.update(activated: true)
      cookies[token_access_key] = cookie_token
      payload = {
        type: 'success',
        msg: "メールアドレスが認証されました。ようこそ#{ENV['APP_NAME']}へ",
        user: @user.my_json,
        exp: _auth.payload[:exp]
      }
    elsif @user.errors.details[:email].include?({ error: :taken })
      payload = { type: 'error', msg: 'メールアドレスはすでに存在します' }
    else
      payload = { type: 'error', msg: '認証に失敗しました。もう一度操作をやり直してください' }
    end
    render json: payload
  end

  private

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
