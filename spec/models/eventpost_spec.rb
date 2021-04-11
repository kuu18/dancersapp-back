require 'rails_helper'

RSpec.describe Eventpost, type: :model do
  describe Eventpost do
    let(:user) { create(:user) }
    let(:eventpost) { build(:eventpost, user: user) }

    # user_idのvalidationテスト

    describe 'user_id validation' do
      # user_idが存在する場合は有効であること
      context 'when present' do
        it 'is valid ' do
          eventpost.user_id = user.id
          expect(eventpost).to be_valid
        end
      end
      # user_idが空の場合は無効であること

      context 'when eventpost is nil' do
        it 'is invalid when nil' do
          eventpost.user_id = nil
          expect(eventpost).to be_invalid
        end
      end
    end
    # contentのvalidationテスト

    describe 'content validation' do
      # contentが存在する場合は有効であること
      context 'when present' do
        it 'is valid ' do
          eventpost.content = 'EventContent'
          expect(eventpost).to be_valid
        end
      end
      # contentが空の場合は無効であること

      context 'when content is nil' do
        it 'is invalid' do
          eventpost.content = nil
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include('イベント概要を入力してください')
        end
      end
      # contentが140文字より長い場合は無効であること

      context 'when length is more than 140 characters' do
        it 'is invalid' do
          eventpost.content = 'a' * 141
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include('イベント概要は140文字以内で入力してください')
        end
      end
    end
    # event_nameのvalidationテスト

    describe 'event_name validation' do
      # event_nameが存在する場合は有効であること
      context 'when present' do
        it 'is valid ' do
          eventpost.event_name = 'EventName'
          expect(eventpost).to be_valid
        end
      end
      # event_nameが空の場合は無効であること

      context 'when event_name is nil' do
        it 'is invalid' do
          eventpost.event_name = '  '
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include('イベント名を入力してください')
        end
      end
      # event_nameが50文字より長い場合は無効であること

      context 'when length is more than 50 characters' do
        it 'is invalid' do
          eventpost.event_name = 'a' * 51
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include('イベント名は50文字以内で入力してください')
        end
      end
    end
    # event_dateのvalidationテスト

    describe 'event_date validation' do
      # event_dateが存在する場合は有効であること
      context 'when present' do
        it 'is valid ' do
          eventpost.event_date = Time.current.since(3.months)
          expect(eventpost).to be_valid
        end
      end
      # event_dateが空の場合は無効であること

      context 'when event_date is nil' do
        it 'is invalid when nil' do
          eventpost.event_date = nil
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include('イベント日を入力してください')
        end
      end
      # 　イベント日が今日以前の場合、無効なこと

      context 'when event_date before today' do
        it 'is invalid' do
          eventpost.event_date = Time.current.yesterday
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include('イベント日は今日以降のものを選択してください')
        end
      end
    end
    # 　イベント日が近い順に並んでいること

    describe 'eventpost order' do
      let(:most_recent) { create(:time_eventpost, :most_recent, user: user) }

      before do
        create(:time_eventpost, :middle, :most_old, user: user)
      end

      it 'order should be most recent event_date first' do
        expect(most_recent).to eq(described_class.first)
      end
    end

    # 画像が添付できること
    describe 'attacth image' do
      context 'when image is attached' do
        before do
          eventpost.image.attach(io: File.open('spec/fixtures/eventpost/test_image.jpeg'), filename: 'test_image.jpeg',
                                 content_type: 'image/jpeg')
        end

        it 'is be trusey' do
          expect(eventpost.image).to be_attached
        end
      end

      context 'when image is not attached' do
        it 'is be falsey' do
          expect(eventpost.image).not_to be_attached
        end
      end
    end

    # 　イベントの関連付けテスト
    describe 'associated like' do
      let(:user) { create(:user) }
      let(:eventpost) { create(:eventpost, user: user) }

      before do
        user.likes.create(eventpost_id: eventpost.id)
      end
      # 　イベントが削除されるといいねが削除されること

      it 'dependent destroy like' do
        expect do
          eventpost.destroy!
        end.to change(Like, :count).by(-1)
      end
    end
  end
end
