class AddIsDeductionToCustomColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :custom_columns, :is_deduction, :boolean, default: true, null: false
  end
end
