class DropYtdTotalsTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :ytd_totals
  end

  def down
    create_table :ytd_totals do |t|
      t.bigint :employee_id
      t.bigint :department_id
      t.bigint :company_id
      t.integer :year, null: false
      t.decimal :hours_worked, default: "0.0"
      t.decimal :overtime_hours_worked, default: "0.0"
      t.decimal :reported_tips, default: "0.0"
      t.decimal :loan_payment, default: "0.0"
      t.decimal :insurance_payment, default: "0.0"
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
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index [:company_id], name: "index_ytd_totals_on_company_id"
      t.index [:department_id], name: "index_ytd_totals_on_department_id"
      t.index [:employee_id], name: "index_ytd_totals_on_employee_id"
    end
  end
end
