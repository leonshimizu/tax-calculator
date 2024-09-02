class CreateDepartments < ActiveRecord::Migration[7.1]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.bigint :company_id, null: false
      t.timestamps
    end

    add_index :departments, :company_id
    add_foreign_key :departments, :companies
  end
end
