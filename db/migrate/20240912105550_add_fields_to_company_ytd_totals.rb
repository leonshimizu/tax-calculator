class AddFieldsToCompanyYtdTotals < ActiveRecord::Migration[7.1]
  def change
    change_table :company_ytd_totals do |t|
      t.decimal :reported_tips, default: 0.0
      t.decimal :loan_payment, default: 0.0
      t.decimal :insurance_payment, default: 0.0
      t.decimal :total_additions, default: 0.0
    end
  end
end
