# db/migrate/20240906000001_create_department_ytd_totals.rb
class CreateDepartmentYtdTotals < ActiveRecord::Migration[7.1]
  def change
    create_table :department_ytd_totals do |t|
      t.references :department, null: false, foreign_key: true
      t.integer :year, null: false
      t.decimal :gross_pay, default: "0.0"
      t.decimal :net_pay, default: "0.0"
      t.decimal :total_deductions, default: "0.0"
      t.jsonb :custom_columns_data, default: {}
      t.timestamps
    end
  end
end
