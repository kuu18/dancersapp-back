class Api::V1::LoginController < ApplicationController
  rescue_from UserAuth.not_found_exception_class, with: :not_found
  before_action :delete_cookie
  before_action :authenticate, only: [:create]

  def create
    cookies[token_access_key] = cookie_token
    render json: {
      exp: _auth.payload[:exp],
      user: _entity.my_json
    }
  end

  def destroy
    head(:ok)
  end

  private

  # メールアドレスからアクティブなユーザーを返す
  def _entity
    @_entity ||= User.find_by(email: auth_params[:email])
  end

  def auth_params
    params.require(:auth).permit(:email, :password)
  end

  def _auth
    @_auth ||= UserAuth::AuthToken.new(payload: { sub: _entity.id })
  end

  def cookie_token
    {
      value: _auth.token,
      expires: Time.zone.at(_auth.payload[:exp]),
      secure: Rails.env.production?,
      http_only: true
    }
  end

  def authenticate
    raise UserAuth.not_found_exception_class unless _entity.present? && _entity.authenticate(auth_params[:password])
  end

  def not_found
    head(:not_found)
  end
end
