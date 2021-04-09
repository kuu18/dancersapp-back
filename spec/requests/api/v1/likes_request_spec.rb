require 'rails_helper'

RSpec.describe 'Api::V1::Likes', type: :request do
  let(:user) { create(:user) }
  let(:eventpost) { create(:eventpost, :default, user: user) }

  before do
    logged_in(user)
  end

  describe 'GET api/v1/likes' do
    before do
      get "/api/v1/likes/?eventpost_id=#{eventpost.id}"
    end

    it 'is response 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'POST api/v1/likes' do
    before do
      post '/api/v1/likes', params: { eventpost_id: eventpost.id }
    end

    it 'is response 201' do
      expect(response.status).to eq 201
    end
  end

  describe 'DELETE api/v1/likes' do
    before do
      user.likes.create(eventpost_id: eventpost.id)
      delete '/api/v1/likes', params: { eventpost_id: eventpost.id }
    end

    it 'is response 200' do
      expect(response.status).to eq 200
    end
  end
end
