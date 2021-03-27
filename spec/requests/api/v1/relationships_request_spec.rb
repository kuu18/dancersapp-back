require 'rails_helper'

RSpec.describe 'Api::V1::Relationships', type: :request do
  describe 'POST /api/v1/relationships' do
    let(:user) { create(:user) }
    let(:other_user) { create(:other_user) }
    # 　ログインしていない場合

    context 'when not logged in' do
      before do
        delete '/api/v1/relationships', params: { user_name: other_user.user_name }
      end
      # 401が帰ってくること

      it 'response 401' do
        expect(response.status).to eq 401
      end
    end

    context 'when logged in' do
      before do
        logged_in(user)
      end
      # 　レスポンス200が帰ってくること

      it 'response 200' do
        post '/api/v1/relationships', params: { user_name: other_user.user_name }
        expect(response.status).to eq 200
      end
      # 　フォロー数が増えていること

      it 'increase follow' do
        expect do
          post '/api/v1/relationships', params: { user_name: other_user.user_name }
        end.to change(user.following, :count).by(1)
      end
    end
  end

  describe 'DELETE /api/v1/relationships' do
    let(:user) { create(:user) }
    let(:other_user) { create(:other_user) }
    # 　ログインしていない場合

    context 'when not logged in' do
      before do
        user.follow(other_user)
        delete '/api/v1/relationships', params: { user_name: other_user.user_name }
      end
      # 401が帰ってくること

      it 'response 400' do
        expect(response.status).to eq 401
      end
    end

    context 'when logged in' do
      before do
        logged_in(user)
        user.follow(other_user)
      end
      # 　レスポンス200が帰ってくること

      it 'response 200' do
        delete '/api/v1/relationships', params: { user_name: other_user.user_name }
        expect(response.status).to eq 200
      end
      # 　フォロー数が減っていること

      it 'increase follow' do
        expect do
          delete '/api/v1/relationships', params: { user_name: other_user.user_name }
        end.to change(user.following, :count).by(-1)
      end
    end
  end
end
