class CreateEmployeeYtdTotals < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_ytd_totals do |t|
      t.references :employee, null: false, foreign_key: true
      t.integer :year
      t.decimal :hours_worked
      t.decimal :overtime_hours_worked
      t.decimal :gross_pay
      t.decimal :net_pay
      t.decimal :withholding_tax
      t.decimal :social_security_tax
      t.decimal :medicare_tax
      t.decimal :retirement_payment
      t.decimal :roth_retirement_payment
      t.decimal :bonus
      t.decimal :total_deductions

      t.timestamps
    end
  end
end
