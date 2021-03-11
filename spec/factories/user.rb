FactoryBot.define do
  factory :user do
    name { 'Test' }
    sequence(:user_name) { |n| "user#{n}_name" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password = 'password'
    password { password }
    password_confirmation { password }
    activated { false }
  end

  factory :other_user, class: 'User' do
    name { 'Test2' }
    sequence(:user_name) { |n| "user#{n}_name" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password = 'password'
    password { password }
    password_confirmation { password }
    activated { false }
  end
end
