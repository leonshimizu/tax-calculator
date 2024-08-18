class ChangeRetirementRateOnEmployees < ActiveRecord::Migration[7.1]
  def change
    change_column_null :employees, :retirement_rate, true
  end
end
