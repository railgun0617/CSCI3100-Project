class BookingMailer < ApplicationMailer

  def booking_confirmation(booking)
    @booking = booking
    @user = booking.user
    @resource = booking.venue || booking.equipment

    mail(
      to: @user.email,
      subject: "Booking Confirmation - #{ @resource.name }"
    )
  end

  def booking_approved(booking)
    @booking = booking
    @user = booking.user
    @resource = booking.venue || booking.equipment

    mail(
      to: @user.email,
      subject: "Your booking has been APPROVED"
    )
  end

  def booking_rejected(booking)
    @booking = booking
    @user = booking.user
    @resource = booking.venue || booking.equipment

    mail(
      to: @user.email,
      subject: "Your booking has been REJECTED"
    )
  end

  
end