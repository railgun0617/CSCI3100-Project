class StaffController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_staff!

  def dashboard
    @bookings = Booking.order(start_time: :desc).all   # <-- use @bookings
  end

  private

  def authorize_staff!
    redirect_to root_path, alert: 'Access denied.' unless current_user.staff?
  end
end