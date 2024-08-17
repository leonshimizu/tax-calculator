class PayrollRecordsController < ApplicationController
  def create
    @employee = Employee.find(params[:employee_id])
    @payroll_record = @employee.payroll_records.new(payroll_record_params)
    if @payroll_record.save
      @payroll_record.calculate_payroll # Assuming this method handles all calculations
      redirect_to employee_path(@employee), notice: 'Payroll record was successfully created and calculated.'
    else
      render 'employees/show'
    end
  end

  def update
    @payroll_record = PayrollRecord.find(params[:id])
    if @payroll_record.update(payroll_record_params)
      @payroll_record.calculate_payroll # Recalculate payroll after update
      redirect_to employee_path(@payroll_record.employee), notice: 'Payroll record was successfully updated and recalculated.'
    else
      render 'edit'
    end
  end

  private
  def payroll_record_params
    params.require(:payroll_record).permit(:hours_worked, :overtime_hours_worked, :reported_tips, :loan_payment, :insurance_payment, :date)
  end

end
