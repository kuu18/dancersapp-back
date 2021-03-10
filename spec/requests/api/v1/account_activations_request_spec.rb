require 'rails_helper'

RSpec.describe 'Api::V1::AccountActivations', type: :request do
  describe 'patch /api/v1/password_resets' do
    let(:user) { create(:user, activated: false) }
    let(:token) { user.to_lifetime_token(2.hours) }
    let(:header) { { Authorization: "Bearer #{token}" } }
    # ヘッダーにトークンがない場合

    context 'when token is nil' do
      before do
        get '/api/v1/account_activations', headers: { Authorization: nil }
      end
      # 401を返し、処理が終了すること

      it 'response 401' do
        expect(response.status).to eq(401)
      end
    end
    # ヘッダーにトークンがある場合

    context 'when token is presence' do
      before do
        get '/api/v1/account_activations', headers: header
      end
      # 200を返すこと

      it 'response 200' do
        expect(response.status).to eq(200)
      end
    end
    # トークンが不正な場合

    context 'when token is invalid' do
      let(:invalid_token) { "#{token}a" }
      let(:invalid_header) { { Authorization: "Bearer #{invalid_token}" } }

      before do
        get '/api/v1/account_activations', headers: invalid_header
      end
      # 401を返すこと

      it 'response 401' do
        expect(response.status).to eq(401)
      end
    end

    # userのアクティブフラグがfalseで
    describe 'when user activated false' do
      # アクティブフラグをtrueに更新できた場合
      context 'when success update true' do
        let(:key) { UserAuth.token_access_key }
        let(:cookie_token) { request.cookie_jar[key] }

        before do
          get '/api/v1/account_activations', headers: header
        end
        # cookieにトークンが保存されてログインしていること

        it 'save access_token to cookie and success login' do
          expect(cookie_token).to be_present
        end
        # type = 'success'が返ってきてること

        it 'correct response type' do
          expect(response_body['type']).to eq 'success'
        end
        # msg = 'メールアドレスが認証されました'が返ってきてること

        it 'correct response msg' do
          expect(response_body['msg']).to eq 'メールアドレスが認証されました。ようこそDancersAppへ'
        end
        # 正しいユーザーが返ってきていること

        it 'correct response user' do
          expect(response_body['user']).to eq user.my_json
        end
        # 正しいcookietokenの有効期限が返ってきていること

        it 'correct response exp' do
          expect(response_body['exp']).to eq 2.weeks.from_now.to_i
        end

        it 'change activated' do
          expect(user.reload.activated).to eq true
        end
      end
      # ユーザーがすでにメールアドレスを登録している時

      context 'when email already taken' do
        before do
          other_user = FactoryBot.create(:user, email: 'test@example.com')
          other_token = other_user.to_lifetime_token(2.hours)
          other_header = { Authorization: "Bearer #{other_token}" }
          user.activated = true
          user.save
          get '/api/v1/account_activations', headers: other_header
        end
        # 200を返すこと

        it 'response 200' do
          expect(response.status).to eq(200)
        end
        # type = 'error'が返ってきてること

        it 'correct response type' do
          expect(response_body['type']).to eq 'error'
        end
        # msg = 'メールアドレスはすでに存在します'が返ってきてること

        it 'correct response msg' do
          expect(response_body['msg']).to eq 'メールアドレスはすでに存在します'
        end
      end
      # 　すでにアクティブフラグがtrueの場合

      context 'when activated is already true' do
        before do
          user.activated = true
          user.save
          get '/api/v1/account_activations', headers: header
        end
        # 200を返すこと

        it 'response 200' do
          expect(response.status).to eq(200)
        end
        # type = 'error'が返ってきてること

        it 'correct response type' do
          expect(response_body['type']).to eq 'error'
        end
        # msg = '認証に失敗しました。もう一度操作をやり直してください'が返ってきてること

        it 'correct response msg' do
          expect(response_body['msg']).to eq '無効なURLです'
        end
      end
    end
    # トークンの有効期限（2時間）が切れている時

    describe 'token life_time' do
      context 'when token is expired' do
        before do
          token = user.to_lifetime_token(2.hours)
          travel_to(2.hours.from_now + 1.minute)
          header = { Authorization: "Bearer #{token}" }
          get '/api/v1/account_activations', headers: header
        end

        it 'response 401' do
          expect(response.status).to eq(401)
        end
      end

      context 'when token is within life_time' do
        before do
          token = user.to_lifetime_token(2.hours)
          travel_to(2.hours.from_now - 1.minute)
          header = { Authorization: "Bearer #{token}" }
          get '/api/v1/account_activations', headers: header
        end

        it 'response 200' do
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
