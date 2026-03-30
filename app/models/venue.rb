class Venue < ApplicationRecord
    belongs_to :tenant, optional: true
end
