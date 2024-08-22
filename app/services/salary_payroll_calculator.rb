class SalaryPayrollCalculator < PayrollCalculator
  def calculate
    # Assume gross_pay is provided directly for salary employees
    calculate_withholding
    calculate_social_security
    calculate_medicare
    calculate_retirement_payment
    calculate_net_pay
  end
end
