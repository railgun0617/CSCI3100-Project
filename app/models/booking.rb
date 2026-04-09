class Booking < ApplicationRecord
    belongs_to :venue, optional: true
    belongs_to :equipment, optional: true
    belongs_to :user

    enum :status, { pending: 'pending', approved: 'approved', cancelled: 'cancelled', rejected: 'rejected' }, default: :pending # booking processing confirmed: 'confirmed',  # booking confirmed

    validates :user, presence: true
    validates :start_time, :end_time, presence: true
    validates :status, presence: true
    validates :booking_type, presence: true, inclusion: { in: %w[venue equipment] } # make sure venue or equipment item is booked in this booking
    validate :booking_duration_limit # Booking must be at least 1 hour and maxmimum is 4 hours
    validate :start_time_not_in_past # Start time must be after the current time
    validate :end_time_after_start_time # end_time must be after start_time

    validate :either_venue_or_equipment # either venue or equipment is booked in one booking
    validate :no_venue_booking_time_conflict, if: ->{ venue.present? } # Only one booking is allowed in a time interval
    validate :within_venue_opening_hours, if: ->{ venue.present? } # The venue must be opening at booking time

    validate :sufficient_equipment, if: ->{ equipment.present? }
    validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }, if: -> { equipment.present? }

    # conflict validation
    validate :no_duplicate_booking_for_same_user_and_slot

    def venue_conflict_exists?
        return false if venue.blank? || start_time.blank? || end_time.blank?
        return false if end_time <= start_time
    
        Booking
        .where(venue_id: venue_id)
        .where.not(id: id)
        .where(status: [:pending, :approved])
        .where("start_time < ? AND end_time > ?", end_time, start_time)
        .exists?  # return bool
    end

    def remaining_equipment
        return false if equipment.blank? || quantity.blank?

        booked_equipment = Booking.where(equipment_id: equipment_id).where.not(id: id).where(status: [:pending, :approved]).sum(:quantity)

        equipment.quantity - booked_equipment
    end

    def sufficient_equipment?
        remaining_equipment >= quantity
    end

    def sufficient_quantity?
        return false if equipment.blank? || quantity.blank?
        remaining_equipment >= quantity
    end

    def approve!
        return false unless pending?
    
        transaction do
            if venue.present? && booking_type == 'venue'
                # venue are needed to check if is available at period
                return false unless venue.is_venue_open?(start_time, end_time)
                return false if venue_conflict_exists?
                update!(status: :approved)
            elsif equipment.present? && booking_type == 'equipment'
                # equipment need to check if there are sufficient quantity
                equipment.with_lock do # avoid over booking
                    return false unless equipment.sufficient_quantity_for_slot?(quantity, start_time, end_time)
                    update!(status: :approved)
                end
            end
        end
        true
    end

    def reject!
        return false unless pending?
        return false if approved?

        transaction do
            if approved? && booking_type == 'equipment'
                equipment.with_lock do
                    equipment.increment_quantity(quantity, lock: false)
                    update!(status: :rejected)
                end
            else
                update!(status: :rejected)
            end
        end
        true
    end

    def deletable_by?(actor)
        return false if actor.nil?
        return true if actor == user
        return true if actor.role == 'staff' || actor.role == 'admin'
        false
    end

    private

    # either venue or equipment is booked in one booking
    def either_venue_or_equipment
        if booking_type == 'venue'
            errors.add(:venue, "id can't be blank") if venue_id.blank?
            errors.add(:equipment, "id must be blank") if equipment_id.present?
        elsif booking_type == 'equipment'
            errors.add(:equipment, "id can't be blank") if equipment_id.blank?
            errors.add(:venue, "id must be blank") if venue_id.present?
        end
    end

    # End time must be after start time
    def end_time_after_start_time
        if start_time.blank? || end_time.blank?
            errors.add(:base, "start_time or end_time is blanked.")
        elsif end_time <= start_time
            errors.add(:end_time, "end_time must be after start_time.")
        end
    end

    # limit duration of booking No more than 4 hours and at least one hour
    def booking_duration_limit
        min_hours = 1
        max_hours = 4

        if start_time.present? && end_time.present? && end_time > start_time
            duration_hours = (end_time - start_time)
            if duration_hours < min_hours.hour
                errors.add(:base, "Booking duration must be at least #{min_hours} hour.")
            elsif duration_hours > max_hours.hour
                errors.add(:base, "Booking duration cannot exceed #{max_hours} hours.")
            end
        end
    end

    # start time must not be in the past
    def start_time_not_in_past
        if start_time.present?
            # Only compare the date, hour, minute, and second without considering time zone
            # Add 8 hours to current time to align with the user's local time (UTC+8) because Time.current is UTC time zone
            current_time = Time.current + 8.hours

            # Convert both times to seconds since midnight for time-of-day comparison
            user_time_of_day = start_time.hour * 3600 + start_time.min * 60 + start_time.sec
            current_time_of_day = current_time.hour * 3600 + current_time.min * 60 + current_time.sec

            # Reject if the booking date is in the past
            if start_time.to_date < Time.current.to_date
                errors.add(:start_time, "cannot be in the past")
            # Reject if it's today but the time has already passed
            elsif start_time.to_date == Time.current.to_date && user_time_of_day < current_time_of_day
                errors.add(:start_time, "cannot be in the past")
            end
        end
    end

    def no_venue_booking_time_conflict
        if venue_conflict_exists?
            errors.add(:base, "This time slot is already been booked for this venue.")
        end
    end

    # It may have problem that does't not select corrsponding venue with venue_id
    def within_venue_opening_hours
        unless venue.is_venue_open?(start_time,end_time)
            errors.add(:base, "Booking time is outside venue opening hours")
        end
    end

    # check if the remain equipment is enough for booking
    def sufficient_equipment
        return if equipment.blank?

        if equipment.quantity < quantity # all quantity check
            errors.add(:base, "#{equipment.name} are no enough.")
        elsif !equipment.sufficient_quantity_for_slot?(quantity, start_time, end_time) # check available quantity in the booked time
            errors.add(:base, "Remain #{equipment.name} are no enough.")
        end
    end

    def no_duplicate_booking_for_same_user_and_slot
        return unless user && (equipment || venue) && start_time && end_time && booking_type

        if booking_type = 'equipment' && equipment.present?
            existing_booking = Booking.where(
                                user_id: user_id,
                                equipment_id: equipment_id,
                                status: ['pending', 'approved'],
                                quantity: quantity,
                                start_time: start_time,
                                end_time: end_time
                            ).where.not(id: id)
        elsif booking_type = 'venue' && venue.present?
            existing_booking = Booking.where(
                                user_id: user_id,
                                venue_id: venue_id,
                                status: ['pending', 'approved'],
                                start_time: start_time,
                                end_time: end_time
                            ).where.not(id: id)
        end

        if existing_booking.exists?
            errors.add(:base, "You already have a booking for this equipment at this time")
            errors.add(:user_id, "already booked this time slot")
        end
    end
end
