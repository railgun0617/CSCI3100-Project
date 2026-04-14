# features/support/database_cleaner.rb
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

Before('@javascript') do
  DatabaseCleaner.strategy = :truncation
end

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end

# 添加这个，确保每次场景前清理
Before do
  Equipment.delete_all
  Venue.delete_all  
  Booking.delete_all
end
