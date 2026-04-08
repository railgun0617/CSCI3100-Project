# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
unless User.find_by(email: "staff@example.com")
  User.create!(
    email: "staff@example.com",
    password: "password123",
    password_confirmation: "password123",
    role: "staff"
  )
  puts "Created staff"
end

# check and create venue
unless Venue.find_by(name: "Library")
  Venue.create!(
    name: "Library",
    description: "A quiet place",
    capacity: 50,
    open_time: "09:00",
    close_time: "16:00",
    latitude: 22.4195,
    longitude: 114.2052
  )
  puts "Created Library"
end

unless Venue.find_by(name: "LT")
  Venue.create!(
    name: "LT",
    description: "LT",
    capacity: 50,
    open_time: "10:00",
    close_time: "17:00",
    latitude: 22.4200,
    longitude: 114.2055
  )
  puts "Created LT"
end

# check and create equipment
unless Equipment.find_by(name: "Laptop")
  Equipment.create!(
    name: "Laptop",
    description: "Dell XPS 13, Windows 11, 16GB RAM",
    quantity: 20,
    location: "IT Support Center",
    latitude: 22.4195,
    longitude: 114.2052
  )
  puts "Created Laptop"
end

unless Equipment.find_by(name: "Projector")
  Equipment.create!(
    name: "Projector",
    description: "HDMI projector, 3000 lumens",
    quantity: 10,
    location: "Wys room 202",
    latitude: 22.4198,
    longitude: 114.2054
  )
  puts "Created Projector"
end

puts "Seed completed successfully!"