require 'rails_helper'

RSpec.describe Relationship, type: :model do
  describe 'relationship validation' do
    let(:relationship) { build(:relationship) }

    context 'when follower_id nil' do
      it 'is invalid' do
        relationship.follower_id = nil
        expect(relationship).to be_invalid
      end
    end

    context 'when followed_id nil' do
      it 'is invalid' do
        relationship.followed_id = nil
        expect(relationship).to be_invalid
      end
    end
  end
end
