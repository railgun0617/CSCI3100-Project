class AddBookingTypeToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :booking_type, :string, null: false, default: "standard"
    add_index :bookings, :booking_type
  end
end
