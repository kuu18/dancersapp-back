require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  describe 'UserAPI' do
    let(:user) { create(:user) }

    before do
      logged_in(user)
    end

    describe '/api/v1/users/current_user' do
      before do
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
