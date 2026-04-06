class Venue < ApplicationRecord

    has_many :bookings, dependent: :destroy
    has_many :users
    belongs_to :tenant, optional: true
    belongs_to :department, optional: true

    validates :open_time, :close_time, presence: true
    validate :close_time_after_open_time

    # check if the time interval is in available operating hours of venue
    # use in model booking
    # to_time may have some problems with translating datetime to time type
    # Comparing may error
    def is_venue_open?(start_t, end_t)
        return false if open_time.blank? || close_time.blank?
    
        # only compare the hours and mins part
        start_t.to_time.strftime("%H:%M") >= open_time.strftime("%H:%M") && 
        end_t.to_time.strftime("%H:%M") <= close_time.strftime("%H:%M")
    end

    private

    def close_time_after_open_time
        if open_time.present? && close_time.present?
            if close_time < open_time
                errors.add(:base, "venue close time must be after open time.")
            end
        end
    end
end