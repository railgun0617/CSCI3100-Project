class Equipment < ApplicationRecord
    belongs_to :tenant, optional: true
    has_many :bookings
end
