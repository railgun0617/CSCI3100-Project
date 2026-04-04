class Booking < ApplicationRecord
    belongs_to :venue, optional: true
    belongs_to :equipment, optional: true
    belongs_to :user
end
