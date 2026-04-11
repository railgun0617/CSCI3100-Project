class BookingChannel < ApplicationCable::Channel
    # auto-call when user connect
    def subscribed
        stream_from "booking_channel"
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

        if conflicting_booking_exists?(resource_type, resource_id, start_time, end_time, quantity)
            transmit({ type: 'book_failed', message: 'This time slot is booked/locked'})
            return
        end

        Booking.transaction do
            if conflicting_booking_exists?(resource_type, resource_id, start_time, end_time, quantity)
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
                if resource_type == 'equipment'
                    remaining_quantity = calculate_remaining_quantity(resource_type, resource_id, start_time, end_time)
    
                    ActionCable.server.broadcast("booking_channel", {
                        type: 'slot_updated',
                        booking_id: booking.id,
                        resource_type: resource_type,
                        resource_id: resource_id,
                        start_time: start_time.iso8601,
                        end_time: end_time.iso8601,
                        remaining_quantity: remaining_quantity,
                        is_fully_booked: remaining_quantity == 0})
                else
                    ActionCable.server.broadcast("booking_channel", {
                        type: 'slot_booked',
                        booking_id: booking.id,
                        resource_type: resource_type,
                        resource_id: resource_id,
                        start_time: start_time.iso8601,
                        end_time: end_time.iso8601})
                end

                resource_name = resource_type == 'venue' ? Venue.find(resource_id).name : Equipment.find(resource_id).name
                user_email = current_user.email
                
                ActionCable.server.broadcast("staff_channel", {
                    type: 'new_booking',
                    booking_id: booking.id,
                    resource_type: resource_type,
                    resource_id: resource_id,
                    resource_name: resource_name,
                    user_email: user_email,
                    start_time: start_time.iso8601,
                    end_time: end_time.iso8601,
                    quantity: quantity,
                    status: 'pending',
                    created_at: Time.now.iso8601 })

                transmit({ type: 'book_success', message: 'Booking submitted! Waiting for approval.', booking_id: booking.id })
                if Rails.application.config.send_emails
                    BookingMailer.booking_confirmation(booking).deliver_later
                end
            else
                transmit({ type: 'book_failed', message: booking.errors.full_messages.to_sentence })
            end
        end
      
        rescue => e
            transmit({ type: 'book_failed', message: "Error: #{e.message}" })
    end

    private

    def conflicting_booking_exists?(resource_type, resource_id, start_time, end_time, requested_quantity)
        base_query = Booking.where(status: ['pending', 'approved'])
                            .where("start_time < ? AND end_time > ?", end_time, start_time)

        if resource_type == 'venue'
            base_query = base_query.where(venue_id: resource_id, booking_type: 'venue')
        else
            equipment = Equipment.find(resource_id)
            total_quantity = equipment.quantity
            
            booked_quantity = base_query.where(equipment_id: resource_id, booking_type: 'equipment')
                                        .sum(:quantity)
            
            remaining_quantity = total_quantity - booked_quantity
            
            if requested_quantity
                return requested_quantity > remaining_quantity
            else
                return remaining_quantity <= 0
            end
        end

        base_query.exists?
    end

    def calculate_remaining_quantity(resource_type, resource_id, start_time, end_time)
        if resource_type == 'equipment'
            equipment = Equipment.find(resource_id)
            total_quantity = equipment.quantity
    
            booked_quantity = Booking.where(
                booking_type: 'equipment',
                equipment_id: resource_id,
                status: ['pending', 'approved']).where("start_time < ? AND end_time > ?", end_time, start_time).sum(:quantity)
    
            return total_quantity - booked_quantity
        else
            return conflicting_booking_exists?(resource_type, resource_id, start_time, end_time) ? 0 : 1
        end
    end
end