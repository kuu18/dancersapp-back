require 'rails_helper'

RSpec.describe 'Api::V1::Comments', type: :request do
  let(:user) { create(:user) }
  let(:eventpost) { create(:eventpost, user: user) }

  before do
    logged_in(user)
  end

  describe 'POST api/v1/comments' do
    before do
      post '/api/v1/comments', params: { comment: { eventpost_id: eventpost.id, content: 'Mycomment' } }
    end

    it 'response 200' do
      expect(response.status).to eq 200
    end

    it 'response correct type' do
      expect(response_body['type']).to eq 'success'
    end

    it 'response correct msg' do
      expect(response_body['msg']).to eq 'コメントしました'
    end
  end

  describe 'DELETE api/v1/comments' do
    before do
      comment = user.comments.create(eventpost_id: eventpost.id, content: 'Mycomment')
      delete '/api/v1/comments', params: { comment_id: comment.id }
    end

    it 'is response 200' do
      expect(response.status).to eq 200
    end
  end
end
