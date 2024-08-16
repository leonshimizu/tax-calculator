class PayrollController < ApplicationController
  def show
    if params[:calculate]
      @total_hours = params[:total_hours].to_f || 0
      @pay_rate = params[:pay_rate].to_f || 0
      @reported_tips = params[:reported_tips].to_f || 0
      @loan = params[:loan].to_f || 0
      @retirement_rate = params[:retirement_rate].to_f / 100 || 0
      @insurance = params[:insurance].to_f || 0
      @filing_status = params[:filing_status]

      @gross_income = (@total_hours * @pay_rate) + @reported_tips
      @withholding_tax = Calculator.calculate_withholding(@gross_income, @filing_status)
      @social_security_tax = Calculator.calculate_social_security(@gross_income)
      @medicare_tax = Calculator.calculate_medicare(@gross_income)
      @retirement_amount = @gross_income * @retirement_rate
      @net_pay = @gross_income - (@withholding_tax + @social_security_tax + @medicare_tax + @loan + @insurance + @retirement_amount)
    end
  end
end
