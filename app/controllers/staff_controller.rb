class StaffController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_staff!

  def dashboard
    if current_user.staff? && current_user.tenant&.name == "Admin"
      # Admin sees all bookings (you may want to show only pending, but keep as is)
      @bookings = Booking.order(start_time: :asc).all
    else
      # Non‑admin staff: only pending bookings for resources in their own tenant
      tenant_id = current_user.tenant_id
      @bookings = Booking.where(status: 'pending')
                         .where(
                           "(venue_id IN (SELECT id FROM venues WHERE tenant_id = ?) OR " \
                           "equipment_id IN (SELECT id FROM equipment WHERE tenant_id = ?))",
                           tenant_id, tenant_id
                         )
                         .order(start_time: :asc)
    end
  end

  private

  def authorize_staff!
    redirect_to root_path, alert: 'Access denied.' unless current_user.staff?
  end
end