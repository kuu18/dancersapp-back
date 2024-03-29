class Eventpost < ApplicationRecord
  include Rails.application.routes.url_helpers
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_many :comments, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :scheduling_users, through: :schedules, source: :user
  has_one_attached :image
  default_scope -> { order(:event_date) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :event_name, presence: true, length: { maximum: 50 }
  validates :event_date, presence: true
  validates :image, content_type: { in: %w[image/jpeg image/gif image/png],
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

  def eventpost_json
    as_json(methods: 'image_url',
            include: [{ user: { only: %i[id name user_name email], methods: 'avatar_url' } },
                      { comments: { only: %i[id content],
                                    include: { user: { methods: 'avatar_url' } } } }])
  end

  def delete_expired_eventpost
    destroy! if event_date < Time.zone.today
  end
end
