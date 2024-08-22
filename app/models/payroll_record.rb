# app/models/payroll_record.rb
class PayrollRecord < ApplicationRecord
  belongs_to :employee

  # Validates that hours worked and date are present
  validates :hours_worked, presence: true, numericality: { greater_than_or_equal_to: 0.01 }
  validates :date, presence: true

  # Callback to calculate payroll details before saving
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
            SUM(retirement_payment) AS total_retirement_payment").first
  }

  def calculate_gross_pay
    overtime_pay = self.overtime_hours_worked.to_f * employee.pay_rate * 1.5
    self.gross_pay = ((self.hours_worked * employee.pay_rate) + overtime_pay + self.reported_tips.to_f).round(2)
  end

  def calculate_total_deductions
    self.total_deductions = [
      withholding_tax,
      social_security_tax,
      medicare_tax,
      loan_payment,
      insurance_payment,
      retirement_payment
    ].map(&:to_f).sum.round(2)
  end

  def update_payroll_details
    calculate_gross_pay if employee.department != 'salary'
    calculate_withholding
    calculate_social_security
    calculate_medicare
    calculate_retirement_payment
    calculate_total_deductions
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
