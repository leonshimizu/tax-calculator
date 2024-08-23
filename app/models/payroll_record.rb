class PayrollRecord < ApplicationRecord
  belongs_to :employee

  # Validations
  validates :hours_worked, presence: true, numericality: { greater_than_or_equal_to: 0.01 }, if: -> { employee.payroll_type != 'salary' }
  validates :date, presence: true

  # Callback to update payroll details before saving
  before_save :update_payroll_details

  # Scope to sum fields for Year-To-Date (YTD) calculations
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

  # Method to update payroll details before saving the record
  def update_payroll_details
    # Calculate gross pay for hourly employees
    calculate_gross_pay if employee.payroll_type != 'salary'

    # Calculate deductions and payments
    calculate_withholding
    calculate_social_security
    calculate_medicare
    calculate_retirement_payment

    # Calculate Roth retirement payment if not provided explicitly
    calculate_roth_retirement_payment if roth_retirement_payment.nil? || roth_retirement_payment == 0.0

    # Calculate total deductions and net pay
    calculate_total_deductions
    calculate_net_pay
  end

  # Method to calculate regular retirement payment
  def calculate_retirement_payment
    self.retirement_payment = (self.gross_pay.to_f * (employee.retirement_rate.to_f / 100)).round(2)
  end

  # Method to calculate Roth retirement payment
  def calculate_roth_retirement_payment
    # Calculate only if not provided explicitly
    self.roth_retirement_payment ||= (self.gross_pay.to_f * (employee.roth_retirement_rate.to_f / 100)).round(2)
  end

  # Method to calculate federal income tax withholding
  def calculate_withholding
    taxable_income = self.gross_pay.to_f - self.roth_retirement_payment.to_f
    self.withholding_tax = Calculator.calculate_withholding(taxable_income, employee.filing_status).round(2)
  end

  # Method to calculate Social Security tax
  def calculate_social_security
    self.social_security_tax = Calculator.calculate_social_security(self.gross_pay).round(2)
  end

  # Method to calculate Medicare tax
  def calculate_medicare
    self.medicare_tax = Calculator.calculate_medicare(self.gross_pay).round(2)
  end

  # Method to calculate total deductions
  def calculate_total_deductions
    self.total_deductions = [
      withholding_tax,
      social_security_tax,
      medicare_tax,
      loan_payment,
      insurance_payment,
      retirement_payment,
      roth_retirement_payment
    ].map(&:to_f).sum.round(2)
  end

  # Method to calculate net pay
  def calculate_net_pay
    self.net_pay = (self.gross_pay.to_f - self.total_deductions).round(2)
  end
end
