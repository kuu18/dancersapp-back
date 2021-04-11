FactoryBot.define do
  factory :eventpost do
    content { 'MyEventContent' }
    event_name { 'MyEvent' }
    event_date { Time.current.since(1.week) }
    user { nil }
  end
  factory :time_eventpost, class: 'Eventpost' do
    trait :middle do
      content { 'MiddleContent' }
      event_name { 'MiddleEvent' }
      event_date { Time.current.since(3.months) }
      user { nil }
    end

    trait :most_recent do
      content { 'MostRecentContent' }
      event_name { 'MostRecent' }
      event_date { Time.current.since(1.month) }
      user { nil }
    end

    trait :most_old do
      content { 'MostOldContent' }
      event_name { 'MostOld' }
      event_date { Time.current.since(1.year) }
      user { nil }
    end
  end
end
