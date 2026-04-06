class AddOpeningHoursToVenues < ActiveRecord::Migration[8.1]
  def change
    add_column :venues, :open_time, :time
    add_column :venues, :close_time, :time
  end
end
