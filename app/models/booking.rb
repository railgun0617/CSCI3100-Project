class Booking < ApplicationRecord
  belongs_to :venue, optional: true
  belongs_to :equipment, optional: true
  belongs_to :user

  enum :status, { pending: 'pending', approved: 'approved', cancelled: 'cancelled', rejected: 'rejected' }, default: :pending

  validates :user, presence: true
  validates :start_time, :end_time, presence: true
  validates :status, presence: true
  validates :booking_type, presence: true, inclusion: { in: %w[venue equipment] }
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }, if: -> { equipment.present? }

  validate :booking_duration_limit
  validate :start_time_not_in_past
  validate :end_time_after_start_time
  validate :either_venue_or_equipment
  validate :no_venue_booking_time_conflict, if: -> { venue.present? }
  validate :within_venue_opening_hours, if: -> { venue.present? }
  validate :sufficient_equipment, if: -> { equipment.present? }
  validate :no_duplicate_booking_for_same_user_and_slot

  # Scopes
  scope :pending, -> { where(status: 'pending') }

  # Conflict detection for venues
  def venue_conflict_exists?
    return false if venue.blank? || start_time.blank? || end_time.blank?
    return false if end_time <= start_time

    Booking
      .where(venue_id: venue_id)
      .where.not(id: id)
      .where(status: [:pending, :approved])
      .where("start_time < ? AND end_time > ?", end_time, start_time)
      .exists?
  end

  # Remaining available quantity of the equipment for the time slot
  def remaining_equipment
    return 0 if equipment.blank? || quantity.blank?

    booked_quantity = Booking
      .where(equipment_id: equipment_id)
      .where.not(id: id)
      .where(status: [:pending, :approved])
      .sum(:quantity)

    equipment.quantity - booked_quantity
  end

  def sufficient_equipment?
    remaining_equipment >= quantity
  end

  # Atomic approval with re‑validation
  def approve!
    return false unless pending?

    transaction do
      if venue.present? && booking_type == 'venue'
        return false unless venue.is_venue_open?(start_time, end_time)
        return false if venue_conflict_exists?
        update_column(:status, 'approved')
      elsif equipment.present? && booking_type == 'equipment'
        equipment.with_lock do
          return false unless equipment.sufficient_quantity_for_slot?(quantity, start_time, end_time, self.id)
          update_column(:status, 'approved')
        end
      end
    end
    true
  end

  # Atomic rejection – only for pending bookings
  def reject!
    return false unless pending?

    transaction do
      # Skip validations – we only need to change the status
      update_column(:status, 'rejected')
    end
    true
  end

  # Cancel an approved (or pending) booking and restore equipment quantity if applicable
  def cancel!
    return false if cancelled? || rejected?

    transaction do
      if equipment.present? && (approved? || pending?)
        equipment.with_lock do
          equipment.increment!(:quantity, quantity)
        end
      end
      update!(status: :cancelled)
    end
    true
  end

  # Authorization for deletion (used in controller)
  def deletable_by?(actor)
    return false if actor.nil?
    return true if actor == user
    return true if actor.staff?
    false
  end
  
  # check if it is locked
  def locked?
    locked_by_id.present? && locked_at.present? && locked_at > 5.minutes.ago
  end

  # check if it is locked by some user
  def locked_by?(user)
    locked? && locked_by_id == user.id
  end

  # release the lock
  def release_lock!
    update!(locked_by_id: nil, locked_at: nil)
  end

  private

  def either_venue_or_equipment
    if booking_type == 'venue'
      errors.add(:venue, "id can't be blank") if venue_id.blank?
      errors.add(:equipment, "id must be blank") if equipment_id.present?
    elsif booking_type == 'equipment'
      errors.add(:equipment, "id can't be blank") if equipment_id.blank?
      errors.add(:venue, "id must be blank") if venue_id.present?
    end
  end

  def end_time_after_start_time
    if start_time.blank? || end_time.blank?
      errors.add(:base, "start_time or end_time is blank.")
    elsif end_time <= start_time
      errors.add(:end_time, "must be after start_time.")
    end
  end

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

  def start_time_not_in_past
    return unless start_time.present?
    if start_time < (Time.zone.now + 8.hours)
      errors.add(:start_time, "cannot be in the past")
    end
  end

  def no_venue_booking_time_conflict
    if venue_conflict_exists?
      errors.add(:base, "This time slot is already booked for this venue.")
    end
  end

  def within_venue_opening_hours
    unless venue.is_venue_open?(start_time, end_time)
      errors.add(:base, "Booking time is outside venue opening hours")
    end
  end

  def sufficient_equipment
    return if equipment.blank? || equipment.quantity.nil?

    if equipment.quantity < quantity
      errors.add(:base, "Not enough #{equipment.name} available (total quantity).")
    elsif !equipment.sufficient_quantity_for_slot?(quantity, start_time, end_time)
      errors.add(:base, "Not enough #{equipment.name} available for the selected time slot.")
    end
  end

  def no_duplicate_booking_for_same_user_and_slot
    return unless user && (equipment || venue) && start_time && end_time && booking_type

    if booking_type == 'equipment' && equipment.present?
      existing = Booking.where(
        user_id: user_id,
        equipment_id: equipment_id,
        status: ['pending', 'approved'],
        start_time: start_time,
        end_time: end_time
      ).where.not(id: id)
    elsif booking_type == 'venue' && venue.present?
      existing = Booking.where(
        user_id: user_id,
        venue_id: venue_id,
        status: ['pending', 'approved'],
        start_time: start_time,
        end_time: end_time
      ).where.not(id: id)
    else
      return
    end

    if existing.exists?
      errors.add(:base, "You already have a booking for this time slot.")
    end
  end
end