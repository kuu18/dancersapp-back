20.times do |n|
  User.limit(50).each do |user|
    id = Faker::Number.between(from: 1, to: 250)
    unless user.likes.exists?(eventpost_id: id)
      like = user.likes.build(
        eventpost_id: id
      )
      like.save!
    end
  end
end

puts "likes = #{Like.count}"