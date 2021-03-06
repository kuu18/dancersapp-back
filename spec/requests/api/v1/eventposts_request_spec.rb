require 'rails_helper'

RSpec.describe 'Api::V1::Eventposts', type: :request do
  describe 'POST /api/v1/eventposts' do
    let(:user) { create(:user) }

    before do
      logged_in(user)
    end

    context 'when valid request' do
      let(:eventpost_params) do
        attributes_for(:eventpost, event_name: 'MyEvent',
                                   content: 'MyEventContent',
                                   event_date: Time.current.since(1.month),
                                   image: fixture_file_upload('/eventpost/test_image.jpeg'))
      end

      it 'response 200' do
        post '/api/v1/eventposts', params: eventpost_params
        expect(response.status).to eq 200
      end

      it 'adds a eventpost' do
        expect do
          post '/api/v1/eventposts', params: eventpost_params
        end.to change(Eventpost, :count).by(1)
      end

      it 'response correct msg' do
        post '/api/v1/eventposts', params: eventpost_params
        expect(response_body['msg']).to include 'イベントを作成しました'
      end

      it 'response correct type' do
        post '/api/v1/eventposts', params: eventpost_params
        expect(response_body['type']).to eq 'success'
      end
    end

    context 'when invalid request' do
      let(:invalid_eventpost_params) do
        attributes_for(:eventpost, event_name: '',
                                   content: '',
                                   event_date: '')
      end

      before do
        post '/api/v1/eventposts', params: invalid_eventpost_params
      end

      it 'response 200' do
        expect(response.status).to eq 200
      end

      it 'response eventpost errors' do
        eventpost = user.eventposts.build(event_name: '', content: '', event_date: '')
        eventpost.save
        errors = eventpost.errors.full_messages
        expect(response_body['errors']).to eq errors
      end

      it 'response correct type' do
        expect(response_body['type']).to eq 'error'
      end
    end
  end

  describe 'DELETE /api/v1/eventposts/:id' do
    context 'when correct user' do
      let(:user) { create(:user) }

      before do
        logged_in(user)
        create(:eventpost, id: 1, user: user)
      end

      it 'response 200' do
        delete '/api/v1/eventposts/1'
        expect(response.status).to eq 200
      end

      it 'delete eventpost' do
        expect do
          delete '/api/v1/eventposts/1'
        end.to change(Eventpost, :count).by(-1)
      end

      it 'response correct msg' do
        delete '/api/v1/eventposts/1'
        expect(response_body['msg']).to include '投稿を削除しました'
      end

      it 'response correct type' do
        delete '/api/v1/eventposts/1'
        expect(response_body['type']).to eq 'success'
      end
    end

    context 'when incorrect user' do
      let(:user) { create(:user) }
      let(:other_user) { create(:other_user) }

      before do
        logged_in(other_user)
        create(:eventpost, id: 1, user: user)
      end

      it 'response 404' do
        delete '/api/v1/eventposts/1'
        expect(response.status).to eq 404
      end

      it 'not delete eventpost' do
        expect do
          delete '/api/v1/eventposts/1'
        end.to change(Eventpost, :count).by(0)
      end
    end
  end

  # 　イベント検索のテスト

  describe 'GET /api/v1/eventposts/search' do
    context 'when search event_name' do
      let(:user) { create(:user) }
      let(:eventpost) { create(:eventpost, event_name: 'Myevent') }

      before do
        logged_in(user)
        get '/api/v1/eventposts/search', params: { event_name_cont: 'event' }
      end

      it 'response 200' do
        expect(response.status).to eq 200
      end
    end

    context 'when search user_date' do
      let(:user) { create(:user) }
      let(:eventpost) { create(:eventpost, event_date: Time.current.since(1.week)) }

      before do
        logged_in(user)
        get '/api/v1/eventposts/search', params: { event_date_gteq: Time.zone.today,
                                                   event_date_lteq_end_of_day: Time.current.since(2.weeks) }
      end

      it 'response 200' do
        expect(response.status).to eq 200
      end
    end
  end
end
