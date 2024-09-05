# db/migrate/20240906000002_create_employee_ytd_totals.rb
class CreateEmployeeYtdTotals < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_ytd_totals do |t|
      t.references :employee, null: false, foreign_key: true
      t.integer :year, null: false
      t.decimal :hours_worked, default: "0.0"
      t.decimal :overtime_hours_worked, default: "0.0"
      t.decimal :gross_pay, default: "0.0"
      t.decimal :net_pay, default: "0.0"
      t.decimal :withholding_tax, default: "0.0"
      t.decimal :social_security_tax, default: "0.0"
      t.decimal :medicare_tax, default: "0.0"
      t.decimal :retirement_payment, default: "0.0"
      t.decimal :roth_retirement_payment, default: "0.0"
      t.decimal :bonus, precision: 12, scale: 3, default: "0.0"
      t.decimal :total_deductions, precision: 12, scale: 3, default: "0.0"
      t.jsonb :custom_columns_data, default: {}
      t.timestamps
    end
  end
end
