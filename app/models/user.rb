require 'validator/email_validator'
class User < ApplicationRecord
  include UserAuth::Tokenizable
  before_validation :downcase_email
  validates :name, presence: true,
                   length: { maximum: 50, allow_blank: true }
  validates :email, presence: true,
                    email: { allow_blank: true }
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
    as_json(only: %i[id name email created_at])
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
