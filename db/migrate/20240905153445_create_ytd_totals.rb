# db/migrate/20240930123456_create_ytd_totals.rb
class CreateYtdTotals < ActiveRecord::Migration[7.1]
  def change
    create_table :ytd_totals do |t|
      t.references :employee, foreign_key: true, index: true
      t.references :department, foreign_key: true, index: true
      t.references :company, foreign_key: true, index: true
      t.integer :year, null: false
      t.decimal :hours_worked, default: 0.0
      t.decimal :overtime_hours_worked, default: 0.0
      t.decimal :reported_tips, default: 0.0
      t.decimal :loan_payment, default: 0.0
      t.decimal :insurance_payment, default: 0.0
      t.decimal :gross_pay, default: 0.0
      t.decimal :net_pay, default: 0.0
      t.decimal :withholding_tax, default: 0.0
      t.decimal :social_security_tax, default: 0.0
      t.decimal :medicare_tax, default: 0.0
      t.decimal :retirement_payment, default: 0.0
      t.decimal :roth_retirement_payment, default: 0.0
      t.decimal :bonus, precision: 12, scale: 3, default: "0.0"
      t.decimal :total_deductions, precision: 12, scale: 3, default: "0.0"
      t.jsonb :custom_columns_data, default: {}

      t.timestamps
    end
  end
end
