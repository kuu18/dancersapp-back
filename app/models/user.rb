require 'validator/email_validator'
class User < ApplicationRecord
  include UserAuth::Tokenizable
  before_validation :downcase_email
  validates :name, presence: true,
                   length: { maximum: 50, allow_blank: true }
  validates :email, presence: true,
                    email: { allow_blank: true },
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

  def my_json
    as_json(only: %i[id name email created_at])
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
