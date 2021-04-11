50.times do
  User.limit(10).each do |user|
    comment = user.comments.build(
      content: Faker::Lorem.sentences,
      eventpost_id: Faker::Number.between(from: 1, to: 250)
    )
    comment.save!
  end
end

puts "comments = #{Comment.count}"