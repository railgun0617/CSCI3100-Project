class AddTenantToVenue < ActiveRecord::Migration[8.1]
  def change
    add_reference :venues, :tenant, foreign_key: true
  end
end
