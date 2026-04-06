Given (/^the venue "(.*?)" exists$/) do |item|
  @venue = Venue.create(
    name: item, description: "Description for #{item}", 
    capacity: "Capacity for #{item}")
end