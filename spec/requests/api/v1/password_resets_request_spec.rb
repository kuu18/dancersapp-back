require 'rails_helper'

RSpec.describe 'Api::V1::PasswordResets', type: :request do
  describe 'post /api/v1/password_resets' do
    let(:active_user) { create(:user, email: 'test@example.com', activated: true) }
    let(:not_active_user) { create(:other_user, email: 'test2@example.com', activated: false) }

    # 　登録済みでないemailの場合
    context 'when email not save' do
      before do
        post '/api/v1/password_resets', params: { password_reset: { email: 'notsave@example.com' } }
      end
      # 200を返すこと

      it 'response 200' do
        expect(response.status).to eq(200)
      end
      # 　msg = 'メールアドレスが見つかりませんでした' が返ってきていること

      it 'response correct message' do
        expect(response_body['msg']).to eq 'メールアドレスが見つかりませんでした'
      end
      # 　type = 'error' が返ってきていること

      it 'response type error' do
        expect(response_body['type']).to eq 'error'
      end
    end
    # 　登録済みでアクティブ済みでない場合

    context 'when email saved and activated false' do
      before do
        ActionMailer::Base.deliveries.clear
        post '/api/v1/password_resets', params: { password_reset: { email: not_active_user.email } }
      end
      # 200を返すこと

      it 'response 200' do
        expect(response.status).to eq(200)
      end
      # 　msg = 'メールアドレスを認証してください' が返ってきていること

      it 'response correct message' do
        expect(response_body['msg']).to eq 'メールアドレスを認証してください'
      end
      # 　type = 'error' が返ってきていること

      it 'response response type error' do
        expect(response_body['type']).to eq 'error'
      end
    end

    context 'when email saved and activated true' do
      before do
        ActionMailer::Base.deliveries.clear
        post '/api/v1/password_resets', params: { password_reset: { email: active_user.email } }
      end
      # 200を返すこと

      it 'response 200' do
        expect(response.status).to eq(200)
      end
      # 　msg = 'パスワード再設定メールを送信しました。30分以内に再設定を完了してください' が返ってきていること

      it 'response correct message' do
        expect(response_body['msg']).to eq 'パスワード再設定メールを送信しました。30分以内に再設定を完了してください'
      end
      # 　type = 'info' が返ってきていること

      it 'response type info' do
        expect(response_body['type']).to eq 'info'
      end
      # 　メールが送信されていること

      it 'send mail' do
        expect(ActionMailer::Base.deliveries.size).to eq 1
      end
    end
  end

  describe 'patch /api/v1/password_resets' do
    let(:user) { create(:user, password: 'password', password_confirmation: 'password') }
    let(:token) { user.to_lifetime_token(2.hours) }
    let(:header) { { Authorization: "Bearer #{token}" } }
    let(:user_params) { { user: { password: 'resetpassword', password_confirmation: 'resetpassword' } } }

    # ヘッダーにトークンがない場合

    context 'when token is nil' do
      before do
        patch '/api/v1/password_resets', params: user_params, headers: { Authorization: nil }
      end
      # 401を返し、処理が終了すること

      it 'response 401' do
        expect(response.status).to eq(401)
      end
    end

    # ヘッダーにトークンがある場合

    context 'when token is presence' do
      before do
        patch '/api/v1/password_resets', params: user_params, headers: header
      end
      # 200を返すこと

      it 'response 200' do
        expect(response.status).to eq(200)
      end
    end

    # トークンが不正な場合

    context 'when token is invalid' do
      let(:invalid_header) { { Authorization: "Bearer #{token}a" } }

      before do
        patch '/api/v1/password_resets', params: user_params, headers: invalid_header
      end
      # 401を返すこと

      it 'response 401' do
        expect(response.status).to eq(401)
      end
    end

    # 　パスワードがからの場合
    context 'when password is nil' do
      let(:nil_params) { { user: { password: '', password_confirmation: '' } } }

      before do
        patch '/api/v1/password_resets', params: nil_params, headers: header
      end

      # レスポンス200が返ってくること

      it 'response 200' do
        expect(response.status).to eq(200)
      end

      # type = 'error'が返ってきてること

      it 'correct response type' do
        expect(response_body['type']).to eq 'error'
      end

      # 正しいエラーメッセージが返ってきてること

      it 'correct response msg' do
        expect(response_body['msg']).to include 'パスワードを入力してください'
      end
    end
    # 　正しいヘッダーとパスワードが送られた時

    context 'when correct request' do
      let(:key) { UserAuth.token_access_key }
      let(:cookie_token) { request.cookie_jar[key] }

      before do
        patch '/api/v1/password_resets', params: user_params, headers: header
      end

      # レスポンス200が返ってくること

      it 'response 200' do
        expect(response.status).to eq(200)
      end

      # cookieにトークンが保存されてログインしていること

      it 'save access_token to cookie and success login' do
        expect(cookie_token).to be_present
      end

      # type = 'success'が返ってきてること

      it 'correct response type' do
        expect(response_body['type']).to eq 'success'
      end

      # 正しいエラーメッセージが返ってきてること

      it 'correct response msg' do
        expect(response_body['msg']).to eq 'パスワードの再設定が完了しました'
      end

      # 正しいユーザーが返ってきていること

      it 'correct response user' do
        expect(response_body['user']).to eq user.my_json
      end
      # 正しいcookietokenの有効期限が返ってきていること

      it 'correct response exp' do
        expect(response_body['exp']).to eq 2.weeks.from_now.to_i
      end
      # userのpasswordが変更されていること

      it 'change password' do
        expect(user.password_digest).not_to eq(user.reload.password_digest)
      end
    end
    # 　updateに失敗した時

    context 'when update is failure' do
      let(:invalid_params) { { user: { password: 'abc__@hbg--ff', password_confirmation: 'abc__@hbg--ff' } } }

      before do
        patch '/api/v1/password_resets', params: invalid_params, headers: header
      end

      # レスポンス200が返ってくること

      it 'response 200' do
        expect(response.status).to eq(200)
      end

      # type = 'error'が返ってきてること

      it 'response type error' do
        expect(response_body['type']).to eq 'error'
      end

      # 正しいエラーメッセージが返ってきてること

      it 'response correct msg' do
        expect(response_body['msg']).to eq 'パスワード再設定に失敗しました。もう一度操作をやり直してください'
      end
    end
  end
end
