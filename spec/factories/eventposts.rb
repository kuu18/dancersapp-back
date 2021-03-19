FactoryBot.define do
  factory :eventpost do

    trait :default do
      content { "MyEventContent" }
      event_name { "MyEvent" }
      event_date { Time.current.since(3.month) }
      association :user
    end

    trait :most_recent do
      content { "MostRecentContent" }
      event_name { "MostRecent" }
      event_date { Time.current.since(1.month) }
      association :user
    end

    trait :most_old do
      content { "MostOldContent" }
      event_name { "MostOld" }
      event_date { Time.current.since(1.years) }
      association :user
    end
  end
end
