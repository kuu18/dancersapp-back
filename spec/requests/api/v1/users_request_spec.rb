require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  describe 'UserAPI' do
    describe 'POST /api/v1/users' do
      context 'when valid request' do
        before do
          ActionMailer::Base.deliveries.clear
        end

        let(:user_params) do
          attributes_for(:user, name: 'Test',
                                user_name: 'user_name',
                                email: 'test@example.com',
                                password: 'password')
        end

        it 'adds a user' do
          expect do
            post '/api/v1/users', params: { user: user_params }
          end.to change(User, :count).by(1)
        end

        it 'response 200' do
          post '/api/v1/users', params: { user: user_params }
          expect(response.status).to eq 200
        end

        it 'send mail' do
          post '/api/v1/users', params: { user: user_params }
          expect(ActionMailer::Base.deliveries.size).to eq 1
        end

        it 'response include type info' do
          post '/api/v1/users', params: { user: user_params }
          expect(response_body['type']).to eq 'info'
        end

        it 'response include correct msg' do
          post '/api/v1/users', params: { user: user_params }
          expect(response_body['msg']).to eq '認証メールを送信しました。２時間以内にメール認証を完了してください'
        end

        it 'response include errors nill' do
          post '/api/v1/users', params: { user: user_params }
          expect(response_body['errors']).to eq nil
        end
      end

      context 'when invalid request' do
        let(:user_params) do
          attributes_for(:user, name: '',
                                email: 'user@invalid',
                                user_name: 'invalid-user-name',
                                password: '')
        end

        it 'does not add a user' do
          expect do
            post '/api/v1/users', params: { user: user_params }
          end.to change(User, :count).by(0)
        end

        it 'response 200' do
          post '/api/v1/users', params: { user: user_params }
          expect(response.status).to eq 200
        end

        it 'response include type error' do
          post '/api/v1/users', params: { user: user_params }
          expect(response_body['type']).to eq 'error'
        end

        it 'response include msg nill' do
          post '/api/v1/users', params: { user: user_params }
          expect(response_body['msg']).to eq nil
        end

        it 'response include errors email' do
          post '/api/v1/users', params: { user: user_params }
          expect(response_body['errors']).to include '名前を入力してください', 'メールアドレスは不正な値です', 'パスワードを入力してください',
                                                     'ユーザーネームは半角英数字•ﾋﾟﾘｵﾄﾞ•ｱﾝﾀﾞｰﾊﾞｰが使えます'
        end
      end

      context 'when email already taken' do
        before do
          FactoryBot.create(:user, email: 'test@example.com', activated: true)
        end

        it 'response include errors already taken' do
          post '/api/v1/users', params: { user: attributes_for(:user, email: 'test@example.com') }
          expect(response_body['errors']).to eq 'メールアドレスはすでに存在します'
        end
      end
    end

    describe 'GET /api/v1/users/current_user' do
      let(:user) { create(:user) }

      before do
        logged_in(user)
        get '/api/v1/users/current_user'
      end

      it 'is resonse 200' do
        expect(response.status).to eq(200)
      end

      it 'is correct response' do
        expect(user.my_json).to eq response_body
      end
    end
  end
end
