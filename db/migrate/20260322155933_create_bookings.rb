class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.integer :user_id
      t.integer :venue_id
      t.integer :equipment_id
      t.datetime :start_time
      t.datetime :end_time
      t.string :status
      t.text :notes

      t.timestamps
    end
  end
end
