# spec/channels/booking_channel_spec.rb
require "rails_helper"

RSpec.describe BookingChannel, type: :channel do
  let(:tenant) { create(:tenant) }
  let(:user)   { create(:user, :staff, tenant: tenant) }

  before do
    stub_connection current_user: user
  end

  describe "#subscribed" do
    it "streams from booking_channel" do
      subscribe
      expect(subscription).to be_confirmed
      expect(subscription.streams).to include("booking_channel")
    end
  end

  describe "#unsubscribed" do
    it "releases locks for current user" do
      equipment = create(:equipment, tenant: tenant)
      booking = create(:booking_equipment,
                       user: user,
                       equipment: equipment,
                       locked_by_id: user.id,
                       locked_at: Time.current)

      subscribe
      perform :unsubscribed
      expect(booking.reload.locked_by_id).to be_nil
    end
  end

  describe "#attempt_book" do
    let(:start_time) { 1.day.from_now.change(hour: 11) }
    let(:end_time)   { start_time + 1.hour }

    it "creates an equipment booking and broadcasts success" do
      equipment = create(:equipment, tenant: tenant, quantity: 2)
      subscribe

      expect {
        perform :attempt_book, {
          "resource_type" => "equipment",
          "resource_id"   => equipment.id,
          "start_time"    => start_time.to_s,
          "end_time"      => end_time.to_s,
          "quantity"      => 1
        }
      }.to have_broadcasted_to("booking_channel").with(hash_including(type: "slot_updated"))

      messages = connection.transmissions.map { |t| t["message"] }.compact
      expect(messages).to include(hash_including("type" => "book_success"))
    end

    it "fails when conflicting booking exists" do
      equipment = create(:equipment, tenant: tenant, quantity: 1)
      create(:booking_equipment, equipment: equipment,
             start_time: start_time, end_time: end_time,
             status: "approved", quantity: 1)

      subscribe
      perform :attempt_book, {
        "resource_type" => "equipment",
        "resource_id"   => equipment.id,
        "start_time"    => start_time.to_s,
        "end_time"      => end_time.to_s,
        "quantity"      => 1
      }

      messages = connection.transmissions.map { |t| t["message"] }.compact
      expect(messages).to include(hash_including("type" => "book_failed"))
    end

    it "creates a venue booking and broadcasts slot_booked" do
      venue = create(:venue, tenant: tenant)
      subscribe

      expect {
        perform :attempt_book, {
          "resource_type" => "venue",
          "resource_id"   => venue.id,
          "start_time"    => (1.day.from_now.change(hour: 10)).to_s,
          "end_time"      => (1.day.from_now.change(hour: 11)).to_s,
          "notes"         => "Team meeting"
        }
      }.to have_broadcasted_to("booking_channel")
        .with(hash_including(type: "slot_booked", resource_type: "venue"))

      messages = connection.transmissions.map { |t| t["message"] }.compact
      expect(messages).to include(hash_including("type" => "book_success"))
    end

    it "fails when booking cannot be saved" do
      venue = create(:venue, tenant: tenant)
      subscribe

      # Force invalid booking (end_time before start_time)
      perform :attempt_book, {
        "resource_type" => "venue",
        "resource_id"   => venue.id,
        "start_time"    => (1.day.from_now.change(hour: 12)).to_s,
        "end_time"      => (1.day.from_now.change(hour: 11)).to_s
      }

      messages = connection.transmissions.map { |t| t["message"] }.compact
      expect(messages).to include(hash_including("type" => "book_failed"))
    end

    it "handles unexpected errors gracefully" do
      venue = create(:venue, tenant: tenant)
      subscribe

      allow(Booking).to receive(:new).and_raise(StandardError.new("boom"))

      perform :attempt_book, {
        "resource_type" => "venue",
        "resource_id"   => venue.id,
        "start_time"    => (1.day.from_now.change(hour: 10)).to_s,
        "end_time"      => (1.day.from_now.change(hour: 11)).to_s
      }

      messages = connection.transmissions.map { |t| t["message"] }.compact
      expect(messages).to include(hash_including("type" => "book_failed", "message" => /boom/))
    end

    it "fails when equipment is fully booked and no quantity provided" do
      equipment = create(:equipment, tenant: tenant, quantity: 1)
      create(:booking_equipment, equipment: equipment,
             start_time: start_time, end_time: end_time,
             status: "approved", quantity: 1)

      subscribe
      perform :attempt_book, {
        "resource_type" => "equipment",
        "resource_id"   => equipment.id,
        "start_time"    => start_time.to_s,
        "end_time"      => end_time.to_s
        # no quantity
      }

      messages = connection.transmissions.map { |t| t["message"] }.compact
      expect(messages).to include(hash_including("type" => "book_failed"))
    end
  end
end
