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
      calculate_gross_pay
    else
      self.gross_pay = gross_pay.to_f + bonus.to_f
    end

    calculate_retirement_payment
    calculate_roth_retirement_payment if roth_retirement_payment.nil? || roth_retirement_payment.zero?

    # Calculate all taxes before total deductions
    calculate_withholding
    calculate_social_security
    calculate_medicare

    # Now calculate total deductions and additions
    calculate_total_deductions_and_additions
    calculate_net_pay
  end

  def calculate_gross_pay
    overtime_pay = (overtime_hours_worked.to_f * employee.pay_rate * 1.5)
    self.gross_pay = ((hours_worked.to_f * employee.pay_rate.to_f) + overtime_pay + reported_tips.to_f).round(2)
  end

  def calculate_retirement_payment
    self.retirement_payment ||= (self.gross_pay.to_f * (employee.retirement_rate.to_f / 100)).round(2)
  end

  def calculate_roth_retirement_payment
    if self.roth_retirement_payment.nil? || self.roth_retirement_payment.zero?
      # Ensure total_deductions and total_additions are not nil
      total_deductions_value = total_deductions.to_f
      total_additions_value = total_additions.to_f

      # Calculate net pay before Roth deduction
      pre_roth_net_pay = self.gross_pay.to_f - total_deductions_value + total_additions_value
      self.roth_retirement_payment = (pre_roth_net_pay * (employee.roth_retirement_rate.to_f / 100)).round(2)
    end
  end

  def calculate_withholding
    total_gross_pay = self.gross_pay.to_f
    taxable_income = total_gross_pay - self.roth_retirement_payment.to_f - other_deductions_not_subject_to_withholding
    self.withholding_tax = Calculator.calculate_withholding(taxable_income, employee.filing_status).round(2)
  end

  def calculate_social_security
    total_gross_pay = self.gross_pay.to_f
    self.social_security_tax = Calculator.calculate_social_security(total_gross_pay).round(2)
  end

  def calculate_medicare
    total_gross_pay = self.gross_pay.to_f
    self.medicare_tax = Calculator.calculate_medicare(total_gross_pay).round(2)
  end

  def other_deductions_not_subject_to_withholding
    # Check if custom_columns_data is not nil and is a Hash
    return 0 unless custom_columns_data.is_a?(Hash)

    # Sum up any other deductions not subject to withholding
    custom_columns_data.select { |_, value| value[:not_subject_to_withholding] }.values.map(&:to_f).sum
  end

  def calculate_total_deductions_and_additions
    if custom_columns_data.is_a?(Hash)
      # Access company through employee
      company = employee.company

      # Use company to find deductions and additions
      custom_column_deductions = custom_columns_data.select do |name, _|
        company.custom_columns.find_by(name: name)&.is_deduction?
      end.values.map(&:to_f).sum

      custom_column_additions = custom_columns_data.reject do |name, _|
        company.custom_columns.find_by(name: name)&.is_deduction?
      end.values.map(&:to_f).sum
    else
      custom_column_deductions = 0.0
      custom_column_additions = 0.0
    end

    # Calculate total deductions with all required components
    self.total_deductions = [
      withholding_tax.to_f,
      social_security_tax.to_f,
      medicare_tax.to_f,
      loan_payment.to_f,
      insurance_payment.to_f,
      retirement_payment.to_f,
      roth_retirement_payment.to_f,
      custom_column_deductions
    ].sum.round(2)

    # Calculate total additions
    self.total_additions = custom_column_additions.round(2)
  end

  def calculate_net_pay
    self.net_pay = (self.gross_pay.to_f - self.total_deductions.to_f + self.total_additions.to_f).round(2)
  end
end
