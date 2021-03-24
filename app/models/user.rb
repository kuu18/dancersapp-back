require 'validator/email_validator'
class User < ApplicationRecord
  include UserAuth::Tokenizable
  has_many :eventposts, dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                  foreign_key: "followed_id",
                                  dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  before_validation :downcase_email
  validates :name, presence: true,
                   length: { maximum: 50, allow_blank: true }
  validates :email, presence: true,
                    email: { allow_blank: true }
  VALID_USER_NAME_REGEX = /\A(?!\.)[\w.]+(?<!\.)\z/.freeze
  validates :user_name, presence: true,
                        length: { minimum: 7, maximum: 50, allow_blank: true },
                        format: {
                          with: VALID_USER_NAME_REGEX,
                          message: :invalid_user_name
                        },
                        uniqueness: { case_sensitive: false }
  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/.freeze
  validates :password, presence: true,
                       length: { minimum: 8 },
                       format: {
                         with: VALID_PASSWORD_REGEX,
                         message: :invalid_password
                       },
                       allow_nil: true
  has_secure_password

  class << self
    # emailからアクティブなユーザーを返す
    def find_activated(email)
      find_by(email: email, activated: true)
    end
  end
  # class method end #########################

  # 自分以外の同じemailのアクティブなユーザーがいる場合にtrueを返す
  def email_activated?
    users = User.where.not(id: id)
    users.find_activated(email).present?
  end

  def my_json
    as_json(only: %i[id name user_name email created_at], include: {active_relationships: { only: %i[follower_id, followed_id] }, passive_relationships: { only: %i[follower_id, followed_id] }})
  end

  def send_email_for(mailer)
    mail = UserMailer.send(mailer, self)
    mail.transport_encoding = '8bit' if Rails.env.development?
    mail.deliver_now
  end

  def feed
    Eventpost.where('user_id = ?', id)
  end

  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
