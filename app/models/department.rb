# app/models/department.rb
class Department < ApplicationRecord
  belongs_to :company
  has_many :employees, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :company_id }

  def calculate_ytd_totals(year)
    totals = initialize_totals
    payroll_records_for_year(year).each do |record|
      totals[:gross_pay] += record.gross_pay.to_f
      totals[:net_pay] += record.net_pay.to_f
      totals[:total_deductions] += record.total_deductions.to_f
      totals[:custom_columns_data].merge!(record.custom_columns_data) { |key, old_val, new_val| old_val + new_val.to_f }
    end
    totals
  end

  private

  def payroll_records_for_year(year)
    PayrollRecord.joins(:employee).where(employees: { department_id: id }).where(date: Date.new(year, 1, 1)..Date.new(year, 12, 31))
  end

  def initialize_totals
    {
      gross_pay: 0.0,
      net_pay: 0.0,
      total_deductions: 0.0,
      custom_columns_data: {}
    }
  end
end
