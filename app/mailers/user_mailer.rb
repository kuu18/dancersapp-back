class UserMailer < ApplicationMailer
  before_action :set_variables
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user)
    life_time = 2.hours
    @token = user.to_lifetime_token(life_time)
    @token_limit = User.time_limit(life_time)
    @url = "#{ENV['BASE_URL']}/account/activations?token=#{@token}"
    mail to: user.email, subject: 'メールアドレスのご確認'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset
    @greeting = 'Hi'

    mail to: 'to@example.org'
  end

  private

  def set_variables
    @app_name = ENV['APP_NAME']
  end
end
