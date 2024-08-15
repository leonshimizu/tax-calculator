# app/controllers/tax_calculator_controller.rb
class TaxCalculatorController < ApplicationController
  def calculate
    @gross_income = params[:gross_income].to_f
    @filing_status = params[:filing_status] || 'single'
    @withholding_tax = WithholdingTaxCalculator.calculate(@gross_income, @filing_status)

    respond_to do |format|
      format.html
      format.json { render json: { gross_income: @gross_income, filing_status: @filing_status, withholding_tax: @withholding_tax } }
    end
  end
end
