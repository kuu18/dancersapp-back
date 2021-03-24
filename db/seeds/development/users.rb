10.times do |n|
  name = "user#{n}"
  email = "#{name}@example.com"
  user_name = "#{name}user_name"
  user = User.find_or_initialize_by(email: email, activated: true)

   if user.new_record?
     user.name = name
     user.user_name = user_name
     user.password = "password"
     user.save!
   end
end

users = User.all
user  = users.first
following = users[2..10]
followers = users[3..10]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }

puts "users = #{User.count}"
puts "relationships = #{Relationship.count}"