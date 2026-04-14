class AddLockFieldsToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :locked_by_id, :integer  # who lock
    add_column :bookings, :locked_at, :datetime    # when lock
    
    add_index :bookings, :locked_by_id
    add_index :bookings, [:venue_id, :start_time, :end_time, :status]
    add_index :bookings, [:equipment_id, :start_time, :end_time, :status]
  end
end
