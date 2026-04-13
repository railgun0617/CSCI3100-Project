class BookingsController < ApplicationController
  before_action :authenticate_user!   # ensure only logged-in users can access

  def index
    if current_user.staff? && current_user.tenant&.name == "Admin"
      @bookings = Booking.order(start_time: :asc).all
    else
      @bookings = current_user.bookings.order(start_time: :asc)
    end
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

    @max_quantities = calculate_max_quantities(@resource, @time_slots) if @resource.is_a?(Equipment)
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
                    alert: "Only #{resource.quantity - booked} items available"
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
      booking_type: resource_type
    )

    if resource_type == "equipment"
      booking.quantity = quantity
    end

    if booking.save
      # Send confirmation email to the user
      if Rails.application.config.send_emails
        BookingMailer.booking_confirmation(booking).deliver_later
      end
      redirect_to bookings_path, 
          notice: "Booking request submitted"
    else
      redirect_to new_booking_path(resource_type: resource_type, resource_id: resource_id),
          alert: booking.errors.full_messages.to_sentence
    end
  end

  def approve
    booking = Booking.find(params[:id])

    unless can_manage_booking?(booking)
      redirect_to staff_dashboard_path, alert: "You are not authorized to approve this booking."
      return
    end

    if booking.approve!
      if Rails.application.config.send_emails
        BookingMailer.booking_approved(booking).deliver_later
      end
      redirect_to staff_dashboard_path, 
                  notice: "Booking approved."
    else
      redirect_to staff_dashboard_path, 
                  alert: "Failed to approve booking."
    end
  end

  def reject
    booking = Booking.find(params[:id])
    unless can_manage_booking?(booking)
      redirect_to staff_dashboard_path, alert: "You are not authorized to reject this booking."
      return
    end

    if  booking.reject!
      if Rails.application.config.send_emails
        BookingMailer.booking_rejected(booking).deliver_later
      end
      redirect_to staff_dashboard_path, 
                  notice: "Booking rejected."
    else
      redirect_to staff_dashboard_path, 
                  alert: "Failed to reject booking."
    end
  end

def destroy
    @booking = Booking.find_by(id: params[:id])

    if @booking.nil?
      redirect_to request.referer || staff_dashboard_path, 
                  alert: "Booking was already deleted or not found."
      return
    end

    # Authorization check
    if current_user == @booking.user || (current_user.staff? && can_manage_booking?(@booking))
      @booking.destroy
      
      respond_to do |format|
        format.html do
          redirect_to request.referer || staff_dashboard_path, 
                      notice: "Booking was successfully deleted."
        end
        format.turbo_stream do
          redirect_to request.referer || staff_dashboard_path, 
                      notice: "Booking was successfully deleted."
        end
      end
    else
      redirect_to request.referer || staff_dashboard_path, 
                  alert: "You are not authorized to delete this booking."
    end
  end

  private

  def generate_time_slots(resource)
    slots = []
    start_date = Date.today
    (0..6).each do |day_offset|
      date = start_date + day_offset
      (9..17).each do |hour|
        slot_start = DateTime.new(date.year, date.month, date.day, hour, 0, 0)
        slot_end = slot_start + 1.hour

        status = if date.saturday? || date.sunday? 
                  "closed"
                elsif slot_start < (Time.current + 8.hours)
                  "closed"
                elsif resource.is_a?(Venue) && !resource.is_venue_open?(slot_start, slot_end)
                  "closed"
                elsif resource.is_a?(Equipment)
                  booked = Booking.where(equipment_id: resource.id, status: [:pending, :approved])
                                  .where("start_time < ? AND end_time > ?", slot_end, slot_start)
                                  .sum(:quantity)
                  resource.quantity - booked > 0 ? "available" : "booked"
                else
                  overlapping_booking = resource.bookings
                    .where(status: ['pending', 'approved'])
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

  def can_manage_booking?(booking)
    # Admin can manage any booking
    return true if current_user.staff? && current_user.tenant&.name == "Admin"
    # Non‑admin staff can only manage bookings for resources in their own tenant
    if current_user.staff?
      tenant_id = current_user.tenant_id
      if booking.venue.present?
        booking.venue.tenant_id == tenant_id
      elsif booking.equipment.present?
        booking.equipment.tenant_id == tenant_id
      else
        false
      end
    else
      false
    end
  end
end