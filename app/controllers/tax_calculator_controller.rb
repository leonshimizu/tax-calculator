# app/controllers/tax_calculator_controller.rb
class TaxCalculatorController < ApplicationController
  def calculate
    @gross_income = params[:gross_income].to_f
    @filing_status = params[:filing_status] || 'single'
    @withholding_tax = Calculator.calculate_withholding(@gross_income, @filing_status)
    @social_security_tax = Calculator.calculate_social_security(@gross_income)
    @medicare_tax = Calculator.calculate_medicare(@gross_income)
  end
end
