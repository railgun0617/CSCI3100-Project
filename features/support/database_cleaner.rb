# features/support/database_cleaner.rb
require 'database_cleaner'

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
