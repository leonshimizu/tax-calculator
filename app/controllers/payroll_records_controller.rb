# app/controllers/payroll_records_controller.rb
class PayrollRecordsController < ApplicationController
  before_action :set_employee
  before_action :set_payroll_record, only: [:show, :edit, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  # GET /employees/:employee_id/payroll_records
  def index
    @payroll_records = @employee.payroll_records.all
  end

  # GET /payroll_records/:id
  def show
  end

  def new
    @payroll_record = @employee.payroll_records.build
  end

  def create
    @payroll_record = @employee.payroll_records.build(payroll_record_params)
    if @payroll_record.save
      redirect_to employee_payroll_record_path(@employee, @payroll_record), notice: 'Payroll record was successfully created.'
    else
      render :new
    end
  end

  # GET /payroll_records/:id/edit
  def edit
  end

  # PATCH/PUT /payroll_records/:id
  def update
    if @payroll_record.update(payroll_record_params)
      redirect_to employee_payroll_record_path(@employee, @payroll_record), notice: 'Payroll record was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /payroll_records/:id
  def destroy
    @payroll_record.destroy
    redirect_to employee_payroll_records_path(@employee), notice: 'Payroll record was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions
  def set_employee
    @employee = Employee.find(params[:employee_id])
  end

  def set_payroll_record
    @payroll_record = PayrollRecord.find(params[:id])
  end

  def handle_not_found
    redirect_to employee_payroll_records_path(@employee), alert: "Employee not found."
  end

  # Only allow a list of trusted parameters through
  def payroll_record_params
    params.require(:payroll_record).permit(:hours_worked, :overtime_hours_worked, :reported_tips, :loan_payment, :insurance_payment, :date)
  end

  # method isn't currently being used but I'd like to keep it here till I verify that won't use it in the future
  # def calculate_payroll_details(payroll_record)
  #   gross_pay = payroll_record.calculate_gross_pay # Assumes a method in PayrollRecord
  #   payroll_record.withholding_tax = Calculator.calculate_withholding(gross_pay, payroll_record.employee.filing_status)
  #   payroll_record.social_security_tax = Calculator.calculate_social_security(gross_pay)
  #   payroll_record.medicare_tax = Calculator.calculate_medicare(gross_pay)
  #   payroll_record.net_pay = Calculator.calculate_net_pay(gross_pay, payroll_record.withholding_tax, payroll_record.social_security_tax, payroll_record.medicare_tax)
  # end
end
