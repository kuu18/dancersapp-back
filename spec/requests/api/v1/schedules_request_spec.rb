require 'rails_helper'

RSpec.describe 'Api::V1::Schedules', type: :request do
  let(:user) { create(:user) }
  let(:eventpost) { create(:eventpost, user: user) }

  before do
    logged_in(user)
  end

  describe 'GET api/v1/schedules' do
    before do
      get "/api/v1/schedules/?eventpost_id=#{eventpost.id}"
    end

    it 'is response 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'POST api/v1/schedules' do
    before do
      post '/api/v1/schedules', params: { eventpost_id: eventpost.id }
    end

    it 'is response 201' do
      expect(response.status).to eq 201
    end
  end

  describe 'DELETE api/v1/schedules' do
    before do
      user.schedules.create(eventpost_id: eventpost.id)
      delete '/api/v1/schedules', params: { eventpost_id: eventpost.id }
    end

    it 'is response 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'GET api/v1/schedules/my_schedules' do
    before do
      get '/api/v1/schedules/my_schedules'
    end

    it 'is response 200' do
      expect(response.status).to eq 200
    end
  end
end
