FactoryBot.define do
  factory :user do
    name { 'Test' }
    email { 'test@example.com' }
    password = 'password'
    password { password }
    password_confirmation { password }
    activated { false }
  end

  factory :other_user, class: 'User' do
    name { 'Test2' }
    email { 'test2@example.com' }
    password = 'password'
    password { password }
    password_confirmation { password }
    activated { false }
  end
end
