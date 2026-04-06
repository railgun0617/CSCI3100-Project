class Equipment < ApplicationRecord
    belongs_to :tenant, optional: true
    has_many :bookings
    has_many :users, through: :bookings

    # decrease the quantity when it is booking
    def decrement_quantity!(amount, lock: true)
        if lock
            with_lock do
                decrement!(:quantity, amount)
            end
        else
            decrement!(:quantity, amount)
        end
    end

    # increase the quantity after booking
    def increment_quantity!(amount, lock: true)
        if lock
            with_lock do
                increment!(:quantity, amount)
            end
        else
            increment!(:quantity, amount)
        end
    end
end
