# app/models/employee.rb
class Employee < ApplicationRecord
  belongs_to :company
  belongs_to :department, optional: true
  has_many :payroll_records, dependent: :destroy
  has_many :employee_ytd_totals, dependent: :destroy

  validates :retirement_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: true }
  validates :roth_retirement_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: true }
  validates :first_name, :last_name, :payroll_type, presence: true
  validates :pay_rate, numericality: { greater_than_or_equal_to: 0.01 }, if: :hourly_employee?

  def calculate_ytd_totals(year)
    totals = initialize_totals
    payroll_records_for_year(year).each do |record|
      totals[:hours_worked] += record.hours_worked.to_f
      totals[:overtime_hours_worked] += record.overtime_hours_worked.to_f
      totals[:gross_pay] += record.gross_pay.to_f
      totals[:net_pay] += record.net_pay.to_f
      totals[:withholding_tax] += record.withholding_tax.to_f
      totals[:social_security_tax] += record.social_security_tax.to_f
      totals[:medicare_tax] += record.medicare_tax.to_f
      totals[:retirement_payment] += record.retirement_payment.to_f
      totals[:roth_retirement_payment] += record.roth_retirement_payment.to_f
      totals[:bonus] += record.bonus.to_f
      totals[:total_deductions] += record.total_deductions.to_f
    end
    update_ytd_totals(totals, year)
  end

  private

  def payroll_records_for_year(year)
    payroll_records.where(date: Date.new(year, 1, 1)..Date.new(year, 12, 31))
  end

  def initialize_totals
    {
      hours_worked: 0.0,
      overtime_hours_worked: 0.0,
      gross_pay: 0.0,
      net_pay: 0.0,
      withholding_tax: 0.0,
      social_security_tax: 0.0,
      medicare_tax: 0.0,
      retirement_payment: 0.0,
      roth_retirement_payment: 0.0,
      bonus: 0.0,
      total_deductions: 0.0
    }
  end

  def update_ytd_totals(totals, year)
    ytd_total = employee_ytd_totals.find_or_initialize_by(year: year)
    ytd_total.update(totals)
    ytd_total # Return the ytd_total object instead of a boolean
  end

  def hourly_employee?
    payroll_type == 'hourly'
  end
end
