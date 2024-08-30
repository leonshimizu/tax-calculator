# app/services/salary_payroll_calculator.rb
class SalaryPayrollCalculator < PayrollCalculator
  def calculate
    calculate_gross_pay # Now includes bonus
    calculate_retirement_payment
    calculate_roth_retirement_payment # Corrected order
    calculate_withholding
    calculate_social_security
    calculate_medicare
    payroll_record.calculate_total_deductions_and_additions # Now called after all individual calculations
    calculate_net_pay
  end

  private

  def calculate_gross_pay
    payroll_record.gross_pay += payroll_record.bonus.to_f
  end
end
