50.times do
  User.limit(5).each do |user|
    eventpost = user.eventposts.build(
      content: Faker::Lorem.paragraph(sentence_count: 3),
      event_name: Faker::FunnyName.name,
      event_date: Faker::Time.forward(days: 100).floor_to(15.minutes)
      )
    eventpost.image.attach(io: File.open('spec/fixtures/test_image.jpeg'), filename: 'test_image.jpeg',
      content_type: 'image/jpeg')
    eventpost.save!
  end
end

puts "eventposts = #{Eventpost.count}"