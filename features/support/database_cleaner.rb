# features/support/database_cleaner.rb
require 'database_cleaner-active_record'

DatabaseCleaner.strategy = :transaction

Before('@javascript') do
  DatabaseCleaner.strategy = :truncation
end

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
