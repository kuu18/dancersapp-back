require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'account_activation' do
    let(:user) { create(:user) }
    let(:life_time) { 2.hours }
    let(:token) { user.to_lifetime_token(life_time) }
    let(:token_limit) { User.time_limit(life_time) }
    let(:mail) { described_class.account_activation(user) }

    describe 'renders the headers' do
      it 'subject eq メールアドレスのご確認' do
        expect(mail.subject).to eq('メールアドレスのご確認')
      end

      it 'to eq user.email' do
        expect(mail.to).to eq([user.email])
      end

      it 'from eq noreply@example.com' do
        expect(mail.from).to eq(['noreply@example.com'])
      end
    end

    describe 'renders the body' do
      it 'APP_NAME eq DancersApp' do
        expect(ENV['APP_NAME']).to eq('DancersApp')
      end

      it 'include APP_NAME' do
        expect(mail.text_part.body.encoded).to match(ENV['APP_NAME'])
        expect(mail.html_part.body.encoded).to match(ENV['APP_NAME'])
      end

      it 'include token' do
        expect(mail.text_part.body.encoded).to match(token)
        expect(mail.html_part.body.encoded).to match(token)
      end

      it 'lifetime_text eq ２時間' do
        expect(token_limit).to eq('2時間')
      end

      it 'include life_time_text' do
        expect(mail.text_part.body.encoded).to match(token_limit)
        expect(mail.html_part.body.encoded).to match(token_limit)
      end
    end
  end

  describe 'password_reset' do
    let(:mail) { described_class.password_reset }

    it 'renders the headers' do
      expect(mail.subject).to eq('Password reset')
      expect(mail.to).to eq(['to@example.org'])
      expect(mail.from).to eq(['noreply@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Hi')
    end
  end
end
