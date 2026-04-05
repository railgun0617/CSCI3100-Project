class BookingsController < ApplicationController
  before_action :authenticate_user!   # ensure only logged-in users can access

  def index
    @bookings = current_user.bookings.order(start_time: :desc)
  end

  def new
    if params[:resource_type] == "venue" && params[:resource_id]
      @resource = Venue.find(params[:resource_id])
    elsif params[:resource_type] == "equipment" && params[:resource_id]
      @resource = Equipment.find(params[:resource_id])
    else
      redirect_to resources_path, alert: "No resource specified for booking."
      return
    end
    @time_slots = generate_time_slots(@resource)
  end

  def create_booking
    resource_type = params[:resource_type]
    resource_id = params[:resource_id]
    start_time = Time.zone.parse(params[:start_time])
    end_time = Time.zone.parse(params[:end_time])

    if resource_type == "venue"
      resource = Venue.find(resource_id)
    elsif resource_type == "equipment"
      resource = Equipment.find(resource_id)
    else
      redirect_to resources_path, alert: "Invalid resource."
      return
    end

    booking = resource.bookings.build(
      user: current_user,
      start_time: start_time,
      end_time: end_time,
      status: "pending",
      booking_type: resource_type # Ensure the type of booking
    )

    if booking.save
      redirect_to bookings_path, notice: "Booking request submitted for #{start_time.strftime('%b %d, %I:%M %p')}."
    else
      redirect_to new_booking_path(resource_type: resource_type, resource_id: resource_id),
                  alert: booking.errors.full_messages.to_sentence
    end
  end

  def approve
    booking = Booking.find(params[:id])
    booking.update(status: 'approved')
    redirect_to staff_dashboard_path, notice: "Booking approved."
  end

  def reject
    booking = Booking.find(params[:id])
    booking.update(status: 'rejected')
    redirect_to staff_dashboard_path, notice: "Booking rejected."
  end

  def destroy
    @booking = Booking.find(params[:id])
    # Only allow the booking owner or a staff member to delete
    if current_user == @booking.user || current_user.staff?
      @booking.destroy
      redirect_to request.referer || bookings_path, notice: "Booking was successfully deleted."
    else
      redirect_to bookings_path, alert: "You are not authorized to delete this booking."
    end
  end

  private

  def generate_time_slots(resource)
    slots = []
    start_date = Date.today
    # Define working hours (9:00 to 18:00, last slot ends at 18:00)
    (0..6).each do |day_offset|
      date = start_date + day_offset
      # Skip weekends if you want (optional)
      # if date.saturday? || date.sunday?
      #   next
      # end
      (9..17).each do |hour|
        slot_start = DateTime.new(date.year, date.month, date.day, hour, 0, 0)
        slot_end = slot_start + 1.hour

        # Determine if the slot is closed (e.g., weekends)
        status = if date.saturday? || date.sunday? 
                  "closed"
                elsif resource.is_a?(Venue) && !resource.is_venue_open?(slot_start, slot_end)
                  "closed" # not in open hours 
                else
                  # Check if there is any booking (pending or approved) that overlaps this time slot
                  overlapping_booking = resource.bookings
                    .where("status IN (?)", ['pending', 'approved'])
                    .where("start_time < ? AND end_time > ?", slot_end, slot_start)
                    .exists?
                  overlapping_booking ? "booked" : "available"
                end

        slots << { time: slot_start, status: status, resource: resource }
      end
    end
    slots
  end
end