require 'rails_helper'

RSpec.describe BookingMailer, type: :mailer do
  let(:tenant)   { create(:tenant) }
  let(:user)     { create(:user, :staff, tenant: tenant) }
  let(:venue)    { create(:venue, tenant: tenant) }
  let(:equipment){ create(:equipment, tenant: tenant) }

  describe "#booking_confirmation" do
    it "sends confirmation email with correct subject and recipient" do
      start_time = (Time.zone.now + 1.day).change(hour: venue.open_time.hour)
      end_time   = start_time + 1.hour
      booking = create(:booking_venue, user: user, venue: venue,
                        start_time: start_time, end_time: end_time)
      mail = BookingMailer.booking_confirmation(booking)

      expect(mail.to).to eq([user.email])
      expect(mail.subject).to eq("Booking Confirmation - #{venue.name}")
      expect(mail.body.encoded).to include("Thank you for booking with us! Your booking request has been successfully submitted and is now <strong>pending approval</strong> by our staff.")

      expect(mail.body.encoded).to include(venue.name)
    end
  end

  describe "#booking_approved" do
    it "sends approved email with correct subject and recipient" do
      booking = create(:booking_equipment, user: user, equipment: equipment, status: "approved")
      mail = BookingMailer.booking_approved(booking)

      expect(mail.to).to eq([user.email])
      expect(mail.subject).to eq("Your booking has been APPROVED")
      expect(mail.body.encoded).to include("Your booking request has been approved by the staff.")
      expect(mail.body.encoded).to include(equipment.name)
    end
  end

  describe "#booking_rejected" do
    it "sends rejected email with correct subject and recipient" do
      booking = create(:booking_equipment, user: user, equipment: equipment, status: "rejected")
      mail = BookingMailer.booking_rejected(booking)

      expect(mail.to).to eq([user.email])
      expect(mail.subject).to eq("Your booking has been REJECTED")
      expect(mail.body.encoded).to include("Unfortunately, your booking request has been rejected by the staff.")
      expect(mail.body.encoded).to include(equipment.name)
    end
  end
end
