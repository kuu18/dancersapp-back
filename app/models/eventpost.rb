class Eventpost < ApplicationRecord
  include Rails.application.routes.url_helpers
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_one_attached :image
  default_scope -> { order(:event_date) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :event_name, presence: true, length: { maximum: 50 }
  validates :event_date, presence: true
  validates :image,  content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: :invalid_eventpost_image },
                      size: { less_than: 5.megabytes,
                              message: :invalid_eventpost_image_size }
  validate :date_before_today

  def date_before_today
    errors.add(:event_date, :invalid_event_date) if
    event_date.present? && event_date < Time.zone.today
  end

  def image_url
    image.attached? ? url_for(image) : nil
  end
end
