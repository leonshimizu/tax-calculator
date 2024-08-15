class TaxCalculatorController < ApplicationController
  def calculate
    # Assign gross_income from the params
    @gross_income = params[:gross_income].to_f
    # Calculate withholding tax
    @withholding_tax = WithholdingTaxCalculator.calculate(@gross_income)

    respond_to do |format|
      format.html # renders the default HTML view
      format.json { render json: { gross_income: @gross_income, withholding_tax: @withholding_tax } }
    end
  end
end
