class CreateVenues < ActiveRecord::Migration[8.1]
  def change
    create_table :venues do |t|
      t.string :name
      t.text :description
      t.integer :capacity
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
