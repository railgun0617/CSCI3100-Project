class Venue < ApplicationRecord

    has_many :bookings, dependent: :destroy
    has_many :users
    belongs_to :tenant
    
    validates :name, uniqueness: true, presence: true
    validates :tenant, presence: true
    validates :description, presence: true
    validates :capacity, presence: true, numericality: { greater_than: 0, only_integer: true }
    validates :latitude, presence: true, numericality: { 
        only_integer: false, 
        allow_nil: false, 
        greater_than_or_equal_to: 0,
        less_than_or_equal_to: 90 }
    validates :longitude, presence: true, numericality: { 
        only_integer: false, 
        allow_nil: false, 
        greater_than_or_equal_to: 0,
        less_than_or_equal_to: 180 }

    validates :open_time, :close_time, presence: true
    validate :close_time_after_open_time
    validate :check_raw_numeric_inputs

    # check if the time interval is in available operating hours of venue
    # use in model booking
    # to_time may have some problems with translating datetime to time type
    # Comparing may error
    def is_venue_open?(start_t, end_t)
        return false if open_time.blank? || close_time.blank?
  
        # use time zone in config
        start_local = start_t.in_time_zone
        end_local = end_t.in_time_zone
        
        # compare 
        start_local.strftime("%H:%M") >= open_time.strftime("%H:%M") && 
        end_local.strftime("%H:%M") <= close_time.strftime("%H:%M")
    end

    private

    def close_time_after_open_time
        if open_time.present? && close_time.present?
            if close_time < open_time
                errors.add(:base, "venue close time must be after open time.")
            end
        end
    end

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
    %w[name description]
  end

  # Ransack: Allow these associations (you can keep them or reduce if you want)
  def self.ransackable_associations(auth_object = nil)
    %w[capacity latitude longitude open_time close_time]   # safe to include even if not searching them
  end

end