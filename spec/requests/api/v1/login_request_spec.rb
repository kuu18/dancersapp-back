require 'rails_helper'

RSpec.describe 'Api::V1::Logins', type: :request do
  let(:user) { create(:user, activated: true) }

  before do
    user_token_logged_in(user)
  end

  describe 'post /api/v1/login' do
    it 'success login' do
      expect(response.status).to eq(200)
    end
  end

  describe 'cookie' do
    let(:key) { UserAuth.token_access_key }
    let(:cookie_token) { request.cookie_jar[key] }

    it 'save access_token to cookie' do
      expect(cookie_token).to be_present
    end

    describe 'cookie options' do
      let(:cookie_options) { request.cookie_jar.instance_variable_get(:@set_cookies)[key.to_s] }

      it 'match expires' do
        exp = UserAuth::AuthToken.new(token: cookie_token).payload['exp']
        expect(Time.zone.at(exp)).to eq cookie_options[:expires]
      end

      it 'is false in development' do
        expect(Rails.env.production?).to eq cookie_options[:secure]
      end

      it 'is true http_only' do
        expect(cookie_options[:http_only]).to be_truthy
      end
    end

    describe 'cookie response' do
      it 'match expires' do
        exp = UserAuth::AuthToken.new(token: cookie_token).payload['exp']
        expect(exp).to eq response_body['exp']
      end

      it 'match user' do
        expect(user.my_json).to eq response_body['user']
      end
    end
  end

  describe 'destroy action' do
    let(:key) { UserAuth.token_access_key }

    describe 'before destroy' do
      it 'present acccess_token in cookie' do
        expect(request.cookie_jar[key]).to be_present
      end
    end

    describe 'after destroy' do
      before do
        delete '/api/v1/logout'
      end

      it 'response 200' do
        expect(response.status).to eq(200)
      end

      it 'cookie is delete' do
        expect(request.cookie_jar[key]).to be_nil
      end
    end
  end
end
