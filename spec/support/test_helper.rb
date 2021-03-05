module TestHelper
  def response_body
    JSON.parse(response.body)
  end

  def logged_in(user)
    cookies[UserAuth.token_access_key] = user.to_token
  end

  def user_token_logged_in(user)
    params = { auth: { email: user.email, password: user.password } }
    post '/api/v1/login', params: params
  end
end
