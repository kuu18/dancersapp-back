require 'rails_helper'

RSpec.describe 'Authenticator', type: :request do
  before do
    @user = create(:user)
    @token = @user.to_token
  end

  describe 'jwt_decode' do
    payload = UserAuth::AuthToken.new(token: @token).payload
    exp = payload[:exp]
    aud = payload[:aud]
    # audienceの値が存在すること
    it 'present aud' do
      expect(aud).to be_present
    end
    # audienceの値は一致していること
    it 'match audience' do
      expect(aud).to eq ENV["API_DOMAIN"]
    end
    # 有効期限が存在すること
    it 'present exp' do
      expect(exp).to be_present
    end
    # 有効期限が2週間であること（秒数切り捨て）
    it 'is two weeks exp' do
      t = 2.week.from_now
      expt = Time.at(exp)
      SEC_PER_MIN = 60
      expect(Time.at(expt.to_i / SEC_PER_MIN * SEC_PER_MIN)).to eq Time.at(t.to_i / SEC_PER_MIN * SEC_PER_MIN)
    end
  end

  describe "authenticate_user_method" do
    key = UserAuth.token_access_key
    # トークンが有効な場合
    describe 'when valid token' do
      before do
        cookies[key] = @token
        get "/api/v1/users/current_user"
      end
      # レスポンス200が返ってくること
      it 'response 200' do
        expect(response.status).to eq(200)
      end
      # @userとcurrent_userは一致していること
      it 'match @user and currenuser' do
        expect(@user).to eq @controller.send(:current_user)
      end
    end
    # トークンが無効な場合
    describe 'when invalid token' do
      before do
        invalid_token = @token + "a"
        cookies[key] = invalid_token
        get "/api/v1/users/current_user"
      end
      # レスポンス401が返ってくること
      it 'response 401' do
        expect(response.status).to eq(401)
      end
      # レスポンスが無いこと
      it 'response is blank' do
        expect(@response.body).to be_blank
      end
    end
    #トークンがnilの場合
    describe 'when token is nil' do
      before do
        cookies[key] = nil
        get "/api/v1/users/current_user"
      end
      # レスポンス401が返ってくること
      it 'response 401' do
        expect(response.status).to eq(401)
      end
    end

    describe 'match @user and current_user within token exp' do
      before do
        travel_to (UserAuth.token_lifetime.from_now - 1.minute)
        cookies[key] = @token
        get "/api/v1/users/current_user"
      end
      it 'response 200' do
        expect(response.status).to eq(200)
      end
      it 'response current_user' do
        expect(@user).to eq @controller.send(:current_user)
      end
    end

    describe 'is not access with out exp token' do
      before do
        travel_to (UserAuth.token_lifetime.from_now + 1.minute)
        cookies[key] = @token
        get "/api/v1/users/current_user"
      end
      it 'response 401' do
        expect(response.status).to eq(401)
      end
    end
    # headerトークンが優先されているか
    describe 'when header_token' do
      before do
        cookies[key] = @token
      end
      it 'prioritize header_token' do
        other_user = create(:other_user)
        header_token = other_user.to_token
        get "/api/v1/users/current_user", headers: { Authorization: "Bearer #{header_token}" }
        expect(header_token).to eq @controller.send(:token)
        expect(other_user).to eq @controller.send(:current_user)
      end
    end
  end
end