99.times do |n|
  name = "user#{n}"
  email = "#{name}@example.com"
  user_name = "#{name}user_name"
  user = User.find_or_initialize_by(email: email, activated: true)

   if user.new_record?
     user.name = name
     user.user_name = user_name
     user.password = "password"
     user.avatar.attach(io: File.open('spec/fixtures/user/default_image.png'), filename: 'default_image.png',
      content_type: 'image/png')
     user.save!
   end
end

users = User.all
user  = users.first
following = users[2..50]
followers = users[3..70]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }

puts "users = #{User.count}"
puts "relationships = #{Relationship.count}"