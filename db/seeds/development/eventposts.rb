10.times do
  User.limit(10).each do |user|
    user.eventposts.create!(
      content: Faker::Lorem.paragraph(sentence_count: 3),
      event_name: Faker::FunnyName.name,
      event_date: Faker::Time.forward(days: 100).floor_to(15.minutes)
      )
  end
end

puts "eventposts = #{Eventpost.count}"