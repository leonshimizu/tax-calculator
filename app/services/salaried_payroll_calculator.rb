class SalariedPayrollCalculator < PayrollCalculator
  def calculate
    # Assume gross_pay is provided directly for salaried employees
    calculate_withholding
    calculate_social_security
    calculate_medicare
    calculate_retirement_payment
    calculate_net_pay
  end
end
