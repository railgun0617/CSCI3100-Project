class AddQuantityToBooking < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :quantity, :integer
  end
end
