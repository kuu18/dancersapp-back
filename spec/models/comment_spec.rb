require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { create(:user) }
  let(:eventpost) { create(:eventpost, user: user) }
  let(:comment) { create(:comment, user: user, eventpost: eventpost) }

  describe 'content validation' do
    # contentが存在する場合は有効であること
    context 'when present' do
      it 'is valid ' do
        comment.content = 'Mycomment'
        expect(comment).to be_valid
      end
    end
    # contentが空の場合は無効であること

    context 'when content is nil' do
      it 'is invalid' do
        comment.content = nil
        expect(comment).to be_invalid
      end
    end
    # contentが140文字より長い場合は無効であること

    context 'when length is more than 140 characters' do
      it 'is invalid' do
        comment.content = 'a' * 141
        expect(comment).to be_invalid
      end
    end
  end

  describe 'comment create' do
    it 'success create' do
      expect do
        user.comments.create(eventpost_id: eventpost.id, content: 'Mycomment')
      end.to change(described_class, :count).by(1)
    end
  end

  describe 'comment destoy' do
    before do
      user.comments.create(eventpost_id: eventpost.id, content: 'Mycomment')
    end

    it 'success destroy' do
      expect do
        comment = described_class.first
        comment.destroy!
      end.to change(described_class, :count).by(-1)
    end
  end
end
