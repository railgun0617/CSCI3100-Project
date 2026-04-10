class BookingChannel < ApplicationCable::Channel
    # auto-call when user connect
    def subscribed
        stream_from "booking_channel"
        broadcast_current_locks
    end

    # auto-call when user disconnect
    def unsubscribed
        Booking.where(locked_by_id: current_user.id).find_each(&:release_lock!)
    end

    def attempt_book(data)
        resource_type = data['resource_type'] # venue / equipment
        resource_id = data['resource_id']
        start_time = Time.zone.parse(data['start_time'])
        end_time = Time.zone.parse(data['end_time'])
        quantity = data['quantity'].to_i if data['quantity'].present?
        notes = data['notes']

        if conflicting_booking_exists?(resource_type, resource_id, start_time, end_time)
            transmit({ type: 'book_failed', message: 'This time slot is booked/locked'})
            return
        end

        Booking.transaction do
            if conflicting_booking_exists?(resource_type, resource_id, start_time, end_time)
                transmit({ type: 'book_failed', message: 'This time slot is booked/locked' })
                return
            end

            booking = Booking.new(
                booking_type: resource_type,
                user_id: current_user.id,
                start_time: start_time,
                end_time: end_time,
                status: 'pending',
                notes: notes
            )

            if resource_type == 'venue'
                booking.venue_id = resource_id
            else
                booking.equipment_id = resource_id
                booking.quantity = quantity
            end

            if booking.save
                 ActionCable.server.broadcast("booking_channel", {
                    type: 'slot_booked',
                    booking_id: booking.id,
                    resource_type: resource_type,
                    resource_id: resource_id,
                    start_time: start_time.iso8601,
                    end_time: end_time.iso8601})

                transmit({ type: 'book_success', message: 'Booking submitted! Waiting for approval.', booking_id: booking.id })
            else
                transmit({ type: 'book_failed', message: booking.errors.full_messages.to_sentence })
            end
        end
      
        rescue => e
            transmit({ type: 'book_failed', message: "Error: #{e.message}" })
        end
    end

    private

    def conflicting_booking_exists?(resource_type, resource_id, start_time, end_time)
        base_query = Booking.where(status: ['pending', 'approved'])
                            .where("start_time < ? AND end_time > ?", end_time, start_time)

        if resource_type == 'venue'
            base_query = base_query.where(venue_id: resource_id, booking_type: 'venue')
        else
            base_query = base_query.where(equipment_id: resource_id, booking_type: 'equipment')
        end

        base_query.exists?
    end
end