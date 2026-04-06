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

    @max_quantities = calculate_max_quantities(@resource, @time_slots) if @resource.is_a?(Equipment) # calculate max quantity for each timeslot
  end

  def create_booking
    resource_type = params[:resource_type]
    resource_id = params[:resource_id]
    start_time = Time.zone.parse(params[:start_time])
    end_time = Time.zone.parse(params[:end_time])

    if resource_type == "venue"
      resource = Venue.find(resource_id)
      quantity = nil
    elsif resource_type == "equipment"
      resource = Equipment.find(resource_id)
      quantity = params[:quantity].to_i

      booked = Booking.where(equipment_id: resource_id, status: [:pending, :approved])
                      .where("start_time < ? AND end_time > ?", end_time, start_time)
                      .sum(:quantity)
      
      if quantity > (resource.quantity - booked)
        redirect_to new_booking_path(resource_type: resource_type, resource_id: resource_id),
                    alert: "Only #{resource.total_quantity - booked} items available"
        return
      end
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

    if resource_type == "equipment"
      booking.quantity = quantity
    end

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
                elsif resource.is_a?(Equipment)
                  booked = Booking.where(equipment_id: resource.id, status: [:pending, :approved])
                                  .where("start_time < ? AND end_time > ?", slot_end, slot_start)
                                  .sum(:quantity)
                  resource.quantity - booked > 0 ? "available" : "booked"
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

  def calculate_max_quantities(resource, time_slots)
    max_qty = {}
    time_slots.each do |slot|
      next unless slot[:status] == 'available'
      
      start_t = slot[:time]
      end_t = start_t + 1.hour
      
      booked = Booking.where(equipment_id: resource.id, status: [:pending, :approved])
                      .where("start_time < ? AND end_time > ?", end_t, start_t)
                      .sum(:quantity)
      
      max_qty[slot[:time].to_i] = resource.quantity - booked
    end
    max_qty
  end
end