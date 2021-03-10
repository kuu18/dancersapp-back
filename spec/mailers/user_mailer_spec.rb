require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'account_activation' do
    let(:user) { create(:user) }
    let(:token) { user.to_lifetime_token(2.hours) }
    let(:mail) { described_class.account_activation(user) }

    describe 'renders the headers' do
      it 'subject eq メールアドレスのご確認' do
        expect(mail.subject).to eq("#{ENV['APP_NAME']}のメールアドレスのご確認")
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

      it 'include user name' do
        expect(mail.text_part.body.encoded).to match(user.name)
        expect(mail.html_part.body.encoded).to match(user.name)
      end

      it 'include token' do
        expect(mail.text_part.body.encoded).to match(token)
        expect(mail.html_part.body.encoded).to match(token)
      end

      it 'include life_time 2.hours' do
        expect(mail.text_part.body.encoded).to match('2時間')
        expect(mail.html_part.body.encoded).to match('2時間')
      end
    end
  end

  describe 'password_reset' do
    let(:user) { create(:user) }
    let(:token) { user.to_lifetime_token(30.minutes) }
    let(:mail) { described_class.password_reset(user) }

    describe 'renders the headers' do
      it 'subject eq メールアドレスのご確認' do
        expect(mail.subject).to eq("#{ENV['APP_NAME']}のパスワード再設定のご案内")
      end

      it 'to eq user.email' do
        expect(mail.to).to eq([user.email])
      end

      it 'from eq noreply@example.com' do
        expect(mail.from).to eq(['noreply@example.com'])
      end
    end

    describe 'renders the body' do
      it 'include user name' do
        expect(mail.text_part.body.encoded).to match(user.name)
        expect(mail.html_part.body.encoded).to match(user.name)
      end

      it 'include token' do
        expect(mail.text_part.body.encoded).to match(token)
        expect(mail.html_part.body.encoded).to match(token)
      end

      it 'include life_time 1.hours' do
        expect(mail.text_part.body.encoded).to match('30分')
        expect(mail.html_part.body.encoded).to match('30分')
      end
    end
  end
end
