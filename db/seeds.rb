User.create!( handle: "yoyoger",
              email: "firstuser@example.com",
              password: "foobar",
              password_confirmation: "foobar",
              admin: true,
              activated: true)

30.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(handle:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true)
end

users = User.order(:created_at).take(6)
50.times do 
  users.each do |user| 
    user.microposts.create!(shop_name: Faker::WorldCup.team, menu_name: Faker::Food.dish, content: Faker::Food.description)
  end
end

users = User.all
user = users.first
following = users[1..49]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }