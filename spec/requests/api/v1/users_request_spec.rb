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

    describe 'PATCH /api/v1/users/update_profile' do
      let(:user) { create(:user, name: 'Test', user_name: 'test_user_name') }

      before do
        logged_in(user)
      end
      # 　ユーザー情報の更新に成功した時

      context 'when success update user' do
        before do
          patch '/api/v1/users/update_profile', params: { user: { name: 'Update', user_name: 'update_user_name' } }
        end
        # 　レスポンス200が返ってくること

        it 'response 200' do
          expect(response.status).to eq 200
        end
        # 　msg = プロフィールを変更しましたが返ってきていること

        it 'response correct msg' do
          expect(response_body['msg']).to eq 'プロフィールを変更しました'
        end
        # 　type = successが返ってきていること

        it 'response correct type' do
          expect(response_body['type']).to eq 'success'
        end
        # 　名前がUpdateに変わっていること

        it 'change name Update' do
          expect(user.reload.name).to eq 'Update'
        end
        # 　ユーザーネームがupdate_user_nameに変わっていること

        it 'change user_name update_user_name' do
          expect(user.reload.user_name).to eq 'update_user_name'
        end
      end
      # 　ユーザー情報の変更に失敗した時

      context 'when failure update' do
        before do
          patch '/api/v1/users/update_profile', params: { user: { name: 'Update', user_name: 'update-user-name' } }
        end
        # レスポンス200が返ってくること

        it 'response 200' do
          expect(response.status).to eq 200
        end
        # 　msg = プロフィールの変更に失敗しましたが返ってきていること

        it 'response correct msg' do
          expect(response_body['msg']).to eq 'プロフィールの変更に失敗しました'
        end
        # 　type = errorが返ってきていること

        it 'response correct type' do
          expect(response_body['type']).to eq 'error'
        end
      end
    end

    describe 'PATCH /api/v1/users/chenge_email' do
      let(:user) { create(:user, email: 'test@example.com', activated: true) }

      before do
        ActionMailer::Base.deliveries.clear
        logged_in(user)
      end
      # 　メールアドレスの変更に成功した時

      context 'when success change email' do
        before do
          patch '/api/v1/users/chenge_email', params: { user: { email: 'change_email@example.com' } }
        end
        # 　レスポンス200が返ってくること

        it 'response 200' do
          expect(response.status).to eq 200
        end
        # 　msg = 認証メールを送信しました。２時間以内にメール認証を完了してくださいが返ってきていること

        it 'response correct msg' do
          expect(response_body['msg']).to eq '認証メールを送信しました。２時間以内にメール認証を完了してください'
        end
        # 　type = infoが返ってきていること

        it 'response correct type' do
          expect(response_body['type']).to eq 'info'
        end
        # 　アクティブフラグがfalseになっていること

        it 'change activated false' do
          expect(user.reload.activated).to eq false
        end
        # 　メールアドレスがchange_email@example.comに変わっていること

        it 'change email change_email@example.com' do
          expect(user.reload.email).to eq 'change_email@example.com'
        end
        # 　メールが送信されていること

        it 'send mail' do
          expect(ActionMailer::Base.deliveries.size).to eq 1
        end
      end
      # 　メールアドレスの変更に失敗した時

      context 'when failure change email' do
        before do
          patch '/api/v1/users/chenge_email', params: { user: { email: 'test@example.com' } }
        end
        # レスポンス200が返ってくること

        it 'response 200' do
          expect(response.status).to eq 200
        end
        # 　msg = 'エラーがあります'が返ってきていること

        it 'response correct msg' do
          expect(response_body['msg']).to eq 'エラーがあります'
        end
        # 　type = errorが返ってきていること

        it 'response correct type' do
          expect(response_body['type']).to eq 'error'
        end
      end
    end

    describe 'PATCH /api/v1/users/chenge_password' do
      let(:user) { create(:user, password: 'password') }

      before do
        logged_in(user)
      end
      # 　パスワードの変更に成功した時

      context 'when success change password' do
        before do
          patch '/api/v1/users/chenge_password',
                params: { user: { password: 'change_password', old_password: 'password' } }
        end
        # 　レスポンス200が返ってくること

        it 'response 200' do
          expect(response.status).to eq 200
        end
        # 　msg = パスワードを変更しましたが返ってきていること

        it 'response correct msg' do
          expect(response_body['msg']).to eq 'パスワードを変更しました'
        end
        # 　type = infoが返ってきていること

        it 'response correct type' do
          expect(response_body['type']).to eq 'success'
        end
        # 　パスワードがchange_passwordに変わっていること

        it 'change password to change_password' do
          user.reload
          expect(user.authenticate('password')).to be_falsey
          expect(user.authenticate('change_password')).to eq user
        end
      end
      # 　パスワードの変更に失敗した時

      context 'when failure change password' do
        before do
          patch '/api/v1/users/chenge_password', params: { user: { password: 'password', old_password: 'password' } }
        end
        # レスポンス200が返ってくること

        it 'response 200' do
          expect(response.status).to eq 200
        end
        # 　msg = 'エラーがあります'が返ってきていること

        it 'response correct msg' do
          expect(response_body['msg']).to eq 'エラーがあります'
        end
        # 　type = errorが返ってきていること

        it 'response correct type' do
          expect(response_body['type']).to eq 'error'
        end
      end
      # 　現在のパスワードが違う場合

      context 'when old_password is incorrect' do
        before do
          patch '/api/v1/users/chenge_password',
                params: { user: { password: 'change_password', old_password: 'incorrect_password' } }
        end
        # レスポンス200が返ってくること

        it 'response 200' do
          expect(response.status).to eq 200
        end
        # 　msg = '現在のパスワードが違います'が返ってきていること

        it 'response correct msg' do
          expect(response_body['msg']).to eq '現在のパスワードが違います'
        end
        # 　type = errorが返ってきていること

        it 'response correct type' do
          expect(response_body['type']).to eq 'error'
        end
      end
    end

    describe 'DELETE /api/v1/users' do
      let(:user) { create(:user, password: 'password') }

      before do
        logged_in(user)
      end
      # 　パスワードの認証に成功した時

      context 'when success user_params password authenticate' do
        # 　レスポンス200が返ってくること
        it 'response 200' do
          delete '/api/v1/users', params: { user: { password: 'password' } }
          expect(response.status).to eq 200
        end
        # 　msg = アカウントを削除しましたが返ってきていること

        it 'response correct msg' do
          delete '/api/v1/users', params: { user: { password: 'password' } }
          expect(response_body['msg']).to eq 'アカウントを削除しました'
        end
        # 　type = successが返ってきていること

        it 'response correct type' do
          delete '/api/v1/users', params: { user: { password: 'password' } }
          expect(response_body['type']).to eq 'success'
        end
        # 　ユーザーが削除されていること

        it 'delete user' do
          expect do
            delete '/api/v1/users', params: { user: { password: 'password' } }
          end.to change(User, :count).by(-1)
        end
      end
      # 　パスワードの認証に失敗した時

      context 'when failure user_params password authenticate' do
        # 　レスポンス200が返ってくること
        it 'response 200' do
          delete '/api/v1/users', params: { user: { password: 'incorrect_password' } }
          expect(response.status).to eq 200
        end
        # 　msg = パスワードが違いますが返ってきていること

        it 'response correct msg' do
          delete '/api/v1/users', params: { user: { password: 'incorrect_password' } }
          expect(response_body['msg']).to eq 'パスワードが違います'
        end
        # 　type = errorが返ってきていること

        it 'response correct type' do
          delete '/api/v1/users', params: { user: { password: 'incorrect_password' } }
          expect(response_body['type']).to eq 'error'
        end
        # 　ユーザーが削除されていないこと

        it 'not delete user' do
          expect do
            delete '/api/v1/users', params: { user: { password: 'incorrect_password' } }
          end.to change(User, :count).by(0)
        end
      end
    end
  end
end
