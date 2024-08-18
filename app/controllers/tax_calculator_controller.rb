# app/controllers/tax_calculator_controller.rb
class TaxCalculatorController < ApplicationController
  def calculate
    @gross_pay = params[:gross_pay].to_f
    @filing_status = params[:filing_status] || 'single'
    @withholding_tax = Calculator.calculate_withholding(@gross_pay, @filing_status)
    @social_security_tax = Calculator.calculate_social_security(@gross_pay)
    @medicare_tax = Calculator.calculate_medicare(@gross_pay)
  end
end
