# app/models/company.rb
class Company < ApplicationRecord
  has_many :employees, dependent: :destroy
  has_many :departments, dependent: :destroy
  has_many :payroll_records, through: :employees
  has_many :custom_columns, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  # Calculates YTD totals for a given year
  def calculate_ytd_totals(year)
    # Initialize the totals
    totals = {
      hours_worked: 0,
      overtime_hours_worked: 0,
      reported_tips: 0,
      loan_payment: 0,
      insurance_payment: 0,
      gross_pay: 0,
      net_pay: 0,
      withholding_tax: 0,
      social_security_tax: 0,
      medicare_tax: 0,
      retirement_payment: 0,
      roth_retirement_payment: 0,
      bonus: 0,
      total_deductions: 0,
      total_additions: 0,
      custom_columns_data: {} # Ensure this is an empty hash initially
    }

    # Fetch payroll records for the given year
    payroll_records_for_year(year).each do |record|
      totals[:hours_worked] += record.hours_worked.to_f
      totals[:overtime_hours_worked] += record.overtime_hours_worked.to_f
      totals[:reported_tips] += record.reported_tips.to_f
      totals[:loan_payment] += record.loan_payment.to_f
      totals[:insurance_payment] += record.insurance_payment.to_f
      totals[:gross_pay] += record.gross_pay.to_f
      totals[:net_pay] += record.net_pay.to_f
      totals[:withholding_tax] += record.withholding_tax.to_f
      totals[:social_security_tax] += record.social_security_tax.to_f
      totals[:medicare_tax] += record.medicare_tax.to_f
      totals[:retirement_payment] += record.retirement_payment.to_f
      totals[:roth_retirement_payment] += record.roth_retirement_payment.to_f
      totals[:bonus] += record.bonus.to_f
      totals[:total_deductions] += record.total_deductions.to_f
      totals[:total_additions] += record.total_additions.to_f

      # Safely merge custom columns data
      record.custom_columns_data&.each do |key, value|
        totals[:custom_columns_data][key] ||= 0
        totals[:custom_columns_data][key] += value.to_f
      end
    end

    totals
  end

  # Returns payroll records for a specific year
  def payroll_records_for_year(year)
    payroll_records.where(date: Date.new(year, 1, 1)..Date.new(year, 12, 31))
  end
end
