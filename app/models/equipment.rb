class Equipment < ApplicationRecord
  belongs_to :tenant
  has_many :bookings
  has_many :users, through: :bookings

  validates :name, uniqueness: true, presence: true
  validates :description, :location, presence: true
  validates :tenant, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :latitude, presence: true, numericality: {
    only_integer: false,
    allow_nil: false,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 90
  }
  validates :longitude, presence: true, numericality: {
    only_integer: false,
    allow_nil: false,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 180
  }

  validate :check_raw_numeric_inputs

  def available_quantity_for_slot(start_time, end_time)
    booked = bookings
             .where(status: ['approved', 'pending'])
             .where(start_time: start_time, end_time: end_time)
             .sum(:quantity)
    quantity - booked
  end

  def sufficient_quantity_for_slot?(requested_quantity, start_time, end_time, exclude_booking_id = nil)
    booked = bookings
             .where(status: ['approved', 'pending'])
             .where("start_time < ? AND end_time > ?", end_time, start_time)
    booked = booked.where.not(id: exclude_booking_id) if exclude_booking_id.present?
    booked_quantity = booked.sum(:quantity)
    (quantity - booked_quantity) >= requested_quantity
  end

  def decrement_quantity!(amount, lock: true)
    if lock
      with_lock { decrement!(:quantity, amount) }
    else
      decrement!(:quantity, amount)
    end
  end

  def increment_quantity!(amount, lock: true)
    if lock
      with_lock { increment!(:quantity, amount) }
    else
      increment!(:quantity, amount)
    end
  end

  private

  def check_raw_numeric_inputs
    [:latitude, :longitude].each do |field|
      raw_value = attributes_before_type_cast[field.to_s]
      next if raw_value.blank?

      if raw_value.is_a?(String) && raw_value !~ /\A\d+(?:\.\d+)?\z/
        errors.add(field, "is not a number")
      end
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name description location]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[latitude longitude quantity tenant]   # <-- tenant added, array closed
  end
end