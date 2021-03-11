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

puts "users = #{User.count}"