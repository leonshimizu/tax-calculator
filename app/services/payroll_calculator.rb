class PayrollCalculator
  attr_reader :employee, :payroll_record

  def initialize(employee, payroll_record)
    @employee = employee
    @payroll_record = payroll_record
  end

  def self.for(employee, payroll_record)
    if employee.department == 'salary'
      SalariedPayrollCalculator.new(employee, payroll_record)
    else
      HourlyPayrollCalculator.new(employee, payroll_record)
    end
  end

  def calculate
    raise NotImplementedError, "Subclasses must implement the calculate method"
  end

  private

  def calculate_withholding
    payroll_record.withholding_tax = Calculator.calculate_withholding(payroll_record.gross_pay, employee.filing_status).round(2)
  end

  def calculate_social_security
    payroll_record.social_security_tax = Calculator.calculate_social_security(payroll_record.gross_pay).round(2)
  end

  def calculate_medicare
    payroll_record.medicare_tax = Calculator.calculate_medicare(payroll_record.gross_pay).round(2)
  end

  def calculate_retirement_payment
    payroll_record.retirement_payment = (payroll_record.gross_pay.to_f * (employee.retirement_rate.to_f / 100)).round(2)
  end

  def calculate_net_pay
    total_deductions = [
      payroll_record.withholding_tax,
      payroll_record.social_security_tax,
      payroll_record.medicare_tax,
      payroll_record.loan_payment,
      payroll_record.insurance_payment,
      payroll_record.retirement_payment
    ].map(&:to_f).sum

    payroll_record.net_pay = (payroll_record.gross_pay.to_f - total_deductions).round(2)
  end
end
