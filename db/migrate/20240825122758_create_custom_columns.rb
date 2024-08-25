# db/migrate/XXXXXXXXXX_create_custom_columns.rb
class CreateCustomColumns < ActiveRecord::Migration[7.1]
  def change
    create_table :custom_columns do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.string :data_type, default: 'decimal'
      t.boolean :include_in_payroll, default: true
      t.timestamps
    end
  end
end
