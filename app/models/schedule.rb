class Schedule < ApplicationRecord
  belongs_to :eventpost
  belongs_to :user
  validates :eventpost_id, uniqueness: { scope: :user_id }

  scope :filter_by_post, ->(eventpost_id) { where(eventpost_id: eventpost_id) if eventpost_id }
end
