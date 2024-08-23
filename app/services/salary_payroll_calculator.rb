# app/services/salary_payroll_calculator.rb
class SalaryPayrollCalculator < PayrollCalculator
  def calculate
    # Assume gross_pay is provided directly for salary employees
    calculate_retirement_payment
    calculate_roth_retirement_payment
    calculate_withholding
    calculate_social_security
    calculate_medicare
    calculate_net_pay
  end
end
