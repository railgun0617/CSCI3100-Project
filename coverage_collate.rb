require 'simplecov'

SimpleCov.collate Dir["coverage/**/.resultset.json"] do
  add_filter '/spec/'
  add_filter '/features/'
end
