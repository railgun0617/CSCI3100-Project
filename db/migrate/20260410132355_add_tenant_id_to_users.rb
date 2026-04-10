class AddTenantIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :tenant_id, :integer
  end
end
