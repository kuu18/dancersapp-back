FactoryBot.define do
  factory :user do
    name { 'Test' }
    email { 'test@example.com' }
    password = 'password'
    password { password }
    password_confirmation { password }
  end
end
