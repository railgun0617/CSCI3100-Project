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

    # validate :sufficient_equipment, if: ->{ equipment.present? }
    # validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }, if: -> { equipment.present? }

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
                    return false unless equipment.sufficient_quantity?(quantity)
                    update!(status: :approved)
                end
            end
        end
        true
    end

    def complete!
        return false unless approved?
        return false if status == 'completed'
    
        # check if is on time
        if end_time > Time.current
          errors.add(:base, "Cannot complete booking before the end time")
            return false
        end
    
        transaction do
            if equipment.present? && booking_type == 'equipment'
                equipment.with_lock do
                    #return equipment with correct quantity
                    equipment.increment_quantity!(quantity, lock: false)
                    update!(status: :approved)
                end
            else
                update!(status: :approved)
            end
        end
        true
    end

    def reject!
        return false unless pending? || approved?
        return false if completed?

        if approved? && start_time < 30.minutes.from.now
            errors.add(:base, "30 mins before start time of booking cannot be cancel.")
            return false        
        end

        transaction do
            if approved? && booking_type == 'equipment'
                equipment.with_lock do
                    equipment.increment_quantity(quantity, lock: false)
                    update!(status: :cancelled)
                end
            else
                update!(status: :cancelled)
            end
        end
        true
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
            if start_time < Time.current
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
    def sufficient_equipment_availability
        return if equipment.blank?

        if equipment.quantity > 0
            errors.add(:base, "#{equipment.name} are no enough.")
        end
    end
end
