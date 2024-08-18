class NetPayController < ApplicationController
  def show
    if params[:calculate]
      @regular_hours = params[:regular_hours].to_f || 0
      @regular_pay_rate = params[:regular_pay_rate].to_f || 0
      @regular_pay = @regular_hours * @regular_pay_rate || 0
      @overtime_hours = params[:overtime_hours].to_f || 0
      @overtime_rate = @regular_pay_rate * 1.5
      @overtime_pay = @overtime_hours * @overtime_rate || 0
      @reported_tips = params[:reported_tips].to_f || 0
      @loan = params[:loan].to_f || 0
      @retirement_rate = params[:retirement_rate].to_f / 100 || 0
      @insurance = params[:insurance].to_f || 0
      @filing_status = params[:filing_status]
      
      if @overtime_hours > 0
        @gross_pay = @regular_pay + @overtime_pay + @reported_tips
      else
        @gross_pay = (@regular_hours * @regular_pay_rate) + @reported_tips
      end
      @withholding_tax = Calculator.calculate_withholding(@gross_pay, @filing_status)
      @social_security_tax = Calculator.calculate_social_security(@gross_pay)
      @medicare_tax = Calculator.calculate_medicare(@gross_pay)
      @retirement_amount = @gross_pay * @retirement_rate
      @net_pay = @gross_pay - (@withholding_tax + @social_security_tax + @medicare_tax + @loan + @insurance + @retirement_amount)
    end
  end
end
