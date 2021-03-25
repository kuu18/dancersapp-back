class TestMailer < ApplicationMailer
  default from: 'dancersapp.work <noreply@dancersapp.work>'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.test_mailer.test.subject
  #
  def test
    @greeting = "Hi"

    mail to: "kdai18.kuu@gmail.com"
  end
end
