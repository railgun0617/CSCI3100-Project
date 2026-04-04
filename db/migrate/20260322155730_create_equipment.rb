class CreateEquipment < ActiveRecord::Migration[8.1]
  def change
    create_table :equipment do |t|
      t.string :name
      t.text :description
      t.string :location
      t.integer :quantity
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
