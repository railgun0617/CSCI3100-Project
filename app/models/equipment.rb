class Equipment < ApplicationRecord
    belongs_to :tenant, optional: true
    has_many :bookings
    has_many :users, through: :bookings

    # check available quantity for different time slot
    def available_quantity_for_slot(start_time, end_time)
        booked = bookings
                .where(status: ['approved', 'pending'])
                .where(start_time: start_time, end_time: end_time)
                .sum(:quantity)

        quantity - booked
    end

    def sufficient_quantity_for_slot?(requested_quantity, start_time, end_time)
        available_quantity_for_slot(start_time, end_time) >= requested_quantity
    end

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
