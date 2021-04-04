FactoryBot.define do
  factory :eventpost do
    trait :default do
      content { 'MyEventContent' }
      event_name { 'MyEvent' }
      event_date { Time.current.since(3.months) }
      association :user, factory: :user
    end

    trait :most_recent do
      content { 'MostRecentContent' }
      event_name { 'MostRecent' }
      event_date { Time.current.since(1.month) }
      association :user, factory: :user
    end

    trait :most_old do
      content { 'MostOldContent' }
      event_name { 'MostOld' }
      event_date { Time.current.since(1.year) }
      association :user, factory: :user
    end

    after(:build) do |eventpost|
      eventpost.image.attach(io: File.open('spec/fixtures/eventpost/test_image.jpeg'), filename: 'test_image.jpeg',
                             content_type: 'image/jpeg')
    end
  end
end
