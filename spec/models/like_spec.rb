require 'rails_helper'

RSpec.describe Like, type: :model do
  let(:user) { create(:user) }
  let(:eventpost) { create(:eventpost, :default, user: user) }

  describe 'like create' do
    it 'success create' do
      expect do
        user.likes.create(eventpost_id: eventpost.id)
      end.to change(described_class, :count).by(1)
    end
  end

  describe 'like destoy' do
    before do
      user.likes.create(eventpost_id: eventpost.id)
    end

    it 'success destroy' do
      expect do
        like = described_class.find_by(eventpost_id: eventpost.id, user_id: user.id)
        like.destroy!
      end.to change(described_class, :count).by(-1)
    end
  end
end
