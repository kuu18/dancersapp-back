require 'rails_helper'

RSpec.describe Eventpost, type: :model do
  describe Eventpost do
    let(:user) { create(:user) }
    let(:eventpost) { build(:eventpost, :default, user: user) }

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

      context 'when eventpost is empty' do
        it 'is invalid when " "' do
          eventpost.user_id = '  '
          expect(eventpost).to be_invalid
        end

        it 'is invalid when ""' do
          eventpost.user_id = ''
          expect(eventpost).to be_invalid
        end

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

      context 'when content is empty' do
        required_msg = 'イベント概要を入力してください'
        it 'is invalid when " "' do
          eventpost.content = '  '
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include(required_msg)
        end

        it 'is invalid when ""' do
          eventpost.content = ''
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include(required_msg)
        end

        it 'is invalid when nil' do
          eventpost.content = nil
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include(required_msg)
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

      context 'when event_name is empty' do
        required_msg = 'イベント名を入力してください'
        it 'is invalid when " "' do
          eventpost.event_name = '  '
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include(required_msg)
        end

        it 'is invalid when ""' do
          eventpost.event_name = ''
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include(required_msg)
        end

        it 'is invalid when nil' do
          eventpost.event_name = nil
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include(required_msg)
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

      context 'when event_date is empty' do
        required_msg = 'イベント日を入力してください'
        it 'is invalid when " "' do
          eventpost.event_date = '  '
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include(required_msg)
        end

        it 'is invalid when ""' do
          eventpost.event_date = ''
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include(required_msg)
        end

        it 'is invalid when nil' do
          eventpost.event_date = nil
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include(required_msg)
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
      let(:most_recent) { create(:eventpost, :most_recent) }

      before do
        create(:eventpost, :default, :most_old)
      end

      it 'order should be most recent event_date first' do
        expect(most_recent).to eq(described_class.first)
      end
    end

    # 　画像のバリデーションテスト

    describe 'image validation' do
      context 'when image is present' do
        before do
          eventpost.image = fixture_file_upload('/eventpost/test_image.jpeg')
        end

        it 'is valid ' do
          expect(eventpost).to be_valid
        end
      end

      context 'when image is nil' do
        before do
          eventpost.image.attach(nil)
        end

        it 'is invalid' do
          expect(eventpost).to be_invalid
          expect(eventpost.errors.full_messages).to include('画像を選択してください')
        end
      end
    end
  end
end
