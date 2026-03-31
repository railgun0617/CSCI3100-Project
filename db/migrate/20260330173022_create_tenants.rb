class CreateTenants < ActiveRecord::Migration[8.1]
  def change
    create_table :tenants do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end
  end
end
