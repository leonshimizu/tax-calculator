class AddStatusAndAdminToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :status, :string, default: 'pending'
    add_column :users, :admin, :boolean, default: false
  end
end
