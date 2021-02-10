require "validator/email_validator"
class User < ApplicationRecord
  before_validation :downcase_email
  validates :name, presence: true,
                   length: { maximum: 50, allow_blank: true }
  validates :email, presence: true,
                    email: { allow_blank: true },
                    uniqueness: { case_sensitive: false }
  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
  validates :password, presence: true,
                       length: { minimum: 8 },
                       format: {
                         with: VALID_PASSWORD_REGEX,
                         message: :invalid_password
                       },
                       allow_blank: true
  has_secure_password

  private
    def downcase_email
      self.email.downcase! if email
    end
end
