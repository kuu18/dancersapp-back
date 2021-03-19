class Eventpost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(:event_date) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :event_name, presence: true, length: { maximum: 50 }
  validates :event_date, presence: true
  validate :date_before_today

  def event_json
    as_json(only: %i[content event_name event_date created_at])
  end

  def date_before_today
    errors.add(:event_date, :invalid_event_date) if
    event_date.present? && event_date < Date.today
  end
end
