require 'rails_helper'

RSpec.describe 'Authenticator', type: :request do
  let(:user) { create(:user) }
  let(:token) { user.to_token }

  describe 'jwt_decode' do
    let(:payload) { UserAuth::AuthToken.new(token: token).payload }

    # subjectとユーザーのidが一致すること
    it 'match subject and user.id' do
      expect(payload['sub']).to eq user.id
    end
    # audienceの値が存在すること

    it 'present aud' do
      expect(payload['aud']).to be_present
    end
    # audienceの値は一致していること

    it 'match audience' do
      expect(payload['aud']).to eq ENV['API_DOMAIN']
    end
    # 有効期限が存在すること

    it 'present exp' do
      expect(payload['exp']).to be_present
    end
    # 有効期限が2週間であること（秒数切り捨て）

    it 'is two weeks exp' do
      t = 2.weeks.from_now
      exp = payload['exp']
      sec_per_min = 60
      expect(Time.zone.at(exp.to_i / sec_per_min * sec_per_min)).to eq Time.zone.at(t.to_i / sec_per_min * sec_per_min)
    end
  end

  describe 'authenticate_user_method' do
    # トークンが有効な場合

    describe 'when valid token' do
      before do
        key = UserAuth.token_access_key
        cookies[key] = token
        get '/api/v1/users/current_user'
      end
      # レスポンス200が返ってくること

      it 'response 200' do
        expect(response.status).to eq(200)
      end
      # @userとcurrent_userは一致していること

      it 'match user and currenuser' do
        expect(user).to eq controller.send(:current_user)
      end
    end
    # トークンが無効な場合

    describe 'when invalid token' do
      before do
        key = UserAuth.token_access_key
        invalid_token = "#{token}a"
        cookies[key] = invalid_token
        get '/api/v1/users/current_user'
      end
      # レスポンス401が返ってくること

      it 'response 401' do
        expect(response.status).to eq(401)
      end
      # レスポンスが無いこと

      it 'response is blank' do
        expect(response.body).to be_blank
      end
    end
    # トークンがnilの場合

    describe 'when token is nil' do
      before do
        key = UserAuth.token_access_key
        cookies[key] = nil
        get '/api/v1/users/current_user'
      end
      # レスポンス401が返ってくること

      it 'response 401' do
        expect(response.status).to eq(401)
      end
    end
    # トークンの有効期限内はアクセス可能か

    describe 'match user and current_user within token exp' do
      before do
        key = UserAuth.token_access_key
        cookies[key] = token
        travel_to(UserAuth.token_lifetime.from_now - 1.minute)
        get '/api/v1/users/current_user'
      end

      it 'response 200' do
        expect(response.status).to eq(200)
      end

      it 'response current_user' do
        expect(user).to eq controller.send(:current_user)
      end
    end
    # トークンの有効期限が切れた場合はアクセス不可か

    describe 'is not access with expired token' do
      before do
        key = UserAuth.token_access_key
        cookies[key] = token
        travel_to(UserAuth.token_lifetime.from_now + 1.minute)
        get '/api/v1/users/current_user'
      end

      it 'response 401' do
        expect(response.status).to eq(401)
      end
    end
    # headerトークンが優先されているか

    describe 'when header_token' do
      let(:other_user) { create(:other_user) }
      let(:header_token) { other_user.to_token }

      before do
        key = UserAuth.token_access_key
        cookies[key] = token
        get '/api/v1/users/current_user', headers: { Authorization: "Bearer #{header_token}" }
      end

      it 'prioritize header_token' do
        expect(header_token).to eq controller.send(:token)
      end

      it 'prioritize other_user' do
        expect(other_user).to eq controller.send(:current_user)
      end
    end
  end
end
