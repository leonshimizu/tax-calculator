# app/models/payroll_record.rb
class PayrollRecord < ApplicationRecord
  belongs_to :employee

  # Validates that hours worked and date are present
  validates :hours_worked, presence: true, numericality: { greater_than_or_equal_to: 0.01 }
  validates :date, presence: true

  # Callback to calculate payroll details before saving
  before_save :update_payroll_details

  def calculate_gross_pay
    overtime_pay = self.overtime_hours_worked.to_f * employee.pay_rate * 1.5
    self.gross_pay = ((self.hours_worked * employee.pay_rate) + overtime_pay + self.reported_tips.to_f).round(2)
  end

  def update_payroll_details
    # Calculate all payroll details
    calculate_gross_pay
    calculate_withholding
    calculate_social_security
    calculate_medicare
    calculate_retirement_payment
    calculate_net_pay
  end

  def calculate_net_pay
    # Ensure all are converted to floats to handle nil values gracefully.
    fields = [self.withholding_tax, self.social_security_tax, self.medicare_tax, self.loan_payment, self.insurance_payment, self.retirement_payment]
    total_deductions = fields.map(&:to_f).sum
  
    self.net_pay = (self.gross_pay.to_f - total_deductions).round(2)
  end

  def calculate_withholding
    self.withholding_tax = Calculator.calculate_withholding(self.gross_pay, employee.filing_status).round(2)
  end

  def calculate_social_security
    self.social_security_tax = Calculator.calculate_social_security(self.gross_pay).round(2)
  end

  def calculate_medicare
    self.medicare_tax = Calculator.calculate_medicare(self.gross_pay).round(2)
  end

  def calculate_retirement_payment
    self.retirement_payment = (self.gross_pay.to_f * (employee.retirement_rate.to_f / 100)).round(2)
  end
end
