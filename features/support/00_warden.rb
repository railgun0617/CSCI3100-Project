require 'warden/test/helpers'
World Warden::Test::Helpers
Warden.test_mode!
After do
  Warden.test_reset!
end
