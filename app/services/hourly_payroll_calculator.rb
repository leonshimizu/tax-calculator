# app/services/hourly_payroll_calculator.rb
class HourlyPayrollCalculator < PayrollCalculator
  def calculate
    calculate_gross_pay
    calculate_retirement_payment
    calculate_roth_retirement_payment
    calculate_withholding
    calculate_social_security
    calculate_medicare
    calculate_total_deductions
    calculate_net_pay
  end

  private

  def calculate_gross_pay
    overtime_pay = payroll_record.overtime_hours_worked.to_f * employee.pay_rate * 1.5
    payroll_record.gross_pay = ((payroll_record.hours_worked * employee.pay_rate) + overtime_pay + payroll_record.reported_tips.to_f).round(2)
  end
end
