class Venue < ApplicationRecord
    belongs_to :tenant, optional: true
    has_many :bookings
end
