# app/services/payroll_calculator.rb
class PayrollCalculator
  attr_reader :employee, :payroll_record

  def initialize(employee, payroll_record)
    @employee = employee
    @payroll_record = payroll_record
  end

  def self.for(employee, payroll_record)
    case employee.payroll_type
    when 'salary'
      SalaryPayrollCalculator.new(employee, payroll_record)
    when 'hourly'
      HourlyPayrollCalculator.new(employee, payroll_record)
    else
      raise "Unsupported payroll type: #{employee.payroll_type}"
    end
  end

  def calculate
    raise NotImplementedError, "Subclasses must implement the calculate method"
  end

  private

  def calculate_withholding
    total_gross_pay = payroll_record.gross_pay.to_f
    taxable_income = total_gross_pay - payroll_record.roth_retirement_payment.to_f - other_deductions_not_subject_to_withholding
    payroll_record.withholding_tax = Calculator.calculate_withholding(taxable_income, employee.filing_status).round(2)
  end

  def calculate_social_security
    total_gross_pay = payroll_record.gross_pay.to_f
    payroll_record.social_security_tax = Calculator.calculate_social_security(total_gross_pay).round(2)
  end

  def calculate_medicare
    total_gross_pay = payroll_record.gross_pay.to_f
    payroll_record.medicare_tax = Calculator.calculate_medicare(total_gross_pay).round(2)
  end

  def calculate_retirement_payment
    payroll_record.retirement_payment ||= (payroll_record.gross_pay.to_f * (employee.retirement_rate.to_f / 100)).round(2)
  end

  def calculate_roth_retirement_payment
    if payroll_record.roth_retirement_payment.nil? || payroll_record.roth_retirement_payment.zero?
      pre_roth_net_pay = payroll_record.gross_pay.to_f - payroll_record.total_deductions + payroll_record.total_additions
      payroll_record.roth_retirement_payment = (pre_roth_net_pay * (employee.roth_retirement_rate.to_f / 100)).round(2)
    end
  end

  def other_deductions_not_subject_to_withholding
    payroll_record.custom_columns_data.select { |_, value| value[:not_subject_to_withholding] }.values.map(&:to_f).sum
  end
end
