FactoryBot.define do
  factory :user do
    name { 'Test' }
    sequence(:user_name) { Faker::Alphanumeric.alpha(number: 10) }
    sequence(:email) { Faker::Internet.email }
    password = 'password'
    password { password }
    password_confirmation { password }
    activated { false }
  end

  factory :other_user, class: 'User' do
    name { 'Test2' }
    sequence(:user_name) { Faker::Alphanumeric.alpha(number: 10) }
    sequence(:email) { Faker::Internet.email }
    password = 'password'
    password { password }
    password_confirmation { password }
    activated { false }
  end

  factory :michael, class: 'User' do
    name { 'Michael' }
    sequence(:user_name) { Faker::Alphanumeric.alpha(number: 10) }
    sequence(:email) { Faker::Internet.email }
    password = 'password'
    password { password }
    password_confirmation { password }
    activated { false }
  end
end
