FactoryBot.define do
  factory :comment do
    content { 'MyString' }
    user { nil }
    eventpost { nil }
  end
end
