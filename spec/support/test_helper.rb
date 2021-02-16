module TestHelper
  # 以下、追加
  def api_url(path = '/')
    "#{ENV['BASE_URL']}/api/v1#{path}"
  end

  # コントローラーのJSONレスポンスを受け取る
  def response_body
    JSON.parse(@response.body)
  end

  def logged_in(user)
    cookies[UserAuth.token_access_key] = user.to_token
  end
end
