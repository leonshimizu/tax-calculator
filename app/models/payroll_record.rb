# app/models/payroll_record.rb
class PayrollRecord < ApplicationRecord
  belongs_to :employee

  # Validates that hours worked and date are present
  validates :hours_worked, presence: true, numericality: { greater_than_or_equal_to: 0.01 }
  validates :date, presence: true

  # Callback to calculate payroll details before saving
  before_save :update_payroll_details

  def calculate_gross_pay
    # Calculate gross income based on hours worked, overtime, and tips
    if self.overtime_hours_worked == nil
      self.gross_pay = (self.hours_worked * employee.pay_rate) + 
                          self.reported_tips
    else
      self.gross_pay = (self.hours_worked * employee.pay_rate) + 
                          (self.overtime_hours_worked * employee.pay_rate * 1.5) + 
                          self.reported_tips
    end
  end

  def update_payroll_details
    # Calculate all payroll details
    calculate_gross_pay
    self.withholding_tax = Calculator.calculate_withholding(self.gross_pay, employee.filing_status)
    self.social_security_tax = Calculator.calculate_social_security(self.gross_pay)
    self.medicare_tax = Calculator.calculate_medicare(self.gross_pay)
    calculate_net_pay
  end

  def calculate_net_pay
    # Calculate net pay after all deductions
    total_deductions = self.withholding_tax + self.social_security_tax + self.medicare_tax + self.loan_payment + self.insurance_payment
    self.net_pay = self.gross_pay - total_deductions
  end

  def calculate_withholding
    self.withholding_tax = Calculator.calculate_withholding(self.gross_pay, employee.filing_status)
  end

  def calculate_social_security
    self.social_security_tax = Calculator.calculate_social_security(self.gross_pay)
  end

  def calculate_medicare
    self.medicare_tax = Calculator.calculate_medicare(self.gross_pay)
  end
end