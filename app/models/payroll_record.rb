# app/models/payroll_record.rb
class PayrollRecord < ApplicationRecord
  belongs_to :employee

  validates :hours_worked, presence: true, numericality: { greater_than_or_equal_to: 0.01 }, if: -> { employee.payroll_type != 'salary' }
  validates :date, presence: true

  before_save :update_payroll_details

  scope :sum_fields, -> {
    select("SUM(hours_worked) AS total_hours_worked,
            SUM(overtime_hours_worked) AS total_overtime_hours_worked,
            SUM(reported_tips) AS total_reported_tips,
            SUM(loan_payment) AS total_loan_payment,
            SUM(insurance_payment) AS total_insurance_payment,
            SUM(gross_pay) AS total_gross_pay,
            SUM(net_pay) AS total_net_pay,
            SUM(withholding_tax) AS total_withholding_tax,
            SUM(social_security_tax) AS total_social_security_tax,
            SUM(medicare_tax) AS total_medicare_tax,
            SUM(retirement_payment) AS total_retirement_payment,
            SUM(roth_retirement_payment) AS total_roth_retirement_payment").first
  }

  def update_payroll_details
    if employee.payroll_type == 'hourly'
      calculate_gross_pay # Only calculate gross pay for hourly employees
    end

    calculate_withholding
    calculate_social_security
    calculate_medicare
    calculate_retirement_payment
    calculate_roth_retirement_payment if roth_retirement_payment.nil? || roth_retirement_payment == 0.0
    calculate_total_deductions
    calculate_net_pay
  end

  def calculate_gross_pay
    overtime_pay = overtime_hours_worked.to_f * employee.pay_rate * 1.5
    self.gross_pay = ((hours_worked * employee.pay_rate) + overtime_pay + reported_tips.to_f).round(2)
  end

  def calculate_retirement_payment
    self.retirement_payment = (self.gross_pay.to_f * (employee.retirement_rate.to_f / 100)).round(2)
  end

  def calculate_roth_retirement_payment
    self.roth_retirement_payment ||= (self.gross_pay.to_f * (employee.roth_retirement_rate.to_f / 100)).round(2)
  end

  def calculate_withholding
    taxable_income = self.gross_pay.to_f - self.roth_retirement_payment.to_f
    self.withholding_tax = Calculator.calculate_withholding(taxable_income, employee.filing_status).round(2)
  end

  def calculate_social_security
    self.social_security_tax = Calculator.calculate_social_security(self.gross_pay).round(2)
  end

  def calculate_medicare
    self.medicare_tax = Calculator.calculate_medicare(self.gross_pay).round(2)
  end

  def calculate_total_deductions
    custom_column_deductions = employee.company.custom_columns.sum { |column| self[column.name].to_f }
    self.total_deductions = [
      withholding_tax,
      social_security_tax,
      medicare_tax,
      loan_payment,
      insurance_payment,
      retirement_payment,
      roth_retirement_payment,
      custom_column_deductions
    ].map(&:to_f).sum.round(2)
  end

  def calculate_net_pay
    self.net_pay = (self.gross_pay.to_f - self.total_deductions).round(2)
  end
end
