class AddTenantToEquipment < ActiveRecord::Migration[8.1]
  def change
    add_reference :equipment, :tenant, foreign_key: true
  end
end
