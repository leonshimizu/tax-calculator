# app/models/payroll_record.rb
class PayrollRecord < ApplicationRecord
  belongs_to :employee

  # Method to calculate and update payroll details
  def calculate_payroll
    calculate_gross_income
    self.withholding_tax = Calculator.calculate_withholding(gross_income, employee.filing_status)
    self.social_security_tax = Calculator.calculate_social_security(gross_income)
    self.medicare_tax = Calculator.calculate_medicare(gross_income)
    calculate_net_pay
    save
  end

  private

  # Helper method to calculate gross income
  def calculate_gross_income
    self.gross_income = (employee.pay_rate * hours_worked) + (employee.pay_rate * 1.5 * overtime_hours_worked) + reported_tips
  end

  # Helper method to calculate net pay
  def calculate_net_pay
    total_deductions = withholding_tax + social_security_tax + medicare_tax + loan_payment + insurance_payment + calculate_401k_contribution
    self.net_pay = gross_income - total_deductions
  end

  # Helper method to calculate 401K contributions
  def calculate_401k_contribution
    (gross_income * employee.retirement_rate).round(2)
  end
end
