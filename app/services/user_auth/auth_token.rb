require 'jwt'

module UserAuth
  class AuthToken
    # 追加
    attr_reader :token
    attr_reader :payload, :lifetime

    def initialize(lifetime: nil, payload: {}, token: nil, options: {})
      if token.present?
        @payload, = JWT.decode(token.to_s, decode_key, true, decode_options.merge(options))
        @token = token
      else
        @lifetime = lifetime || UserAuth.token_lifetime
        @payload = claims.merge(payload)
        @token = JWT.encode(@payload, secret_key, algorithm, header_fields)
      end
    end

    # subjectからユーザーを検索する
    def entity_for_user
      User.find @payload['sub']
    end

    private

    # エンコードキー(config/initializers/user_auth.rb)
    def secret_key
      UserAuth.token_secret_signature_key.call
    end

    # デコードキー(config/initializers/user_auth.rb)
    def decode_key
      UserAuth.token_public_key || secret_key
    end

    # アルゴリズム(config/initializers/user_auth.rb)
    def algorithm
      UserAuth.token_signature_algorithm
    end

    # オーディエンスの値がある場合にtrueを返す
    def verify_audience?
      UserAuth.token_audience.present?
    end

    # オーディエンス(config/initializers/user_auth.rb)
    def token_audience
      verify_audience? && UserAuth.token_audience.call
    end

    # トークン有効期限を秒数で返す
    def token_lifetime
      @lifetime.from_now.to_i
    end

    # デコード時オプション
    def decode_options
      {
        aud: token_audience,
        verify_aud: verify_audience?,
        algorithm: algorithm
      }
    end

    def claims
      claims = {}
      claims[:exp] = token_lifetime
      claims[:aud] = token_audience if verify_audience?
      claims
    end

    # エンコード時のヘッダー
    def header_fields
      { typ: 'JWT' }
    end
  end
end
