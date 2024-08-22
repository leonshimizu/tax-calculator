# app/controllers/payroll_records_controller.rb
class PayrollRecordsController < ApplicationController
  before_action :set_company
  before_action :set_employee, only: [:index, :create, :show, :update, :destroy]
  before_action :set_payroll_record, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  # GET /companies/:company_id/employees/:employee_id/payroll_records
  # GET /companies/:company_id/payroll_records
  def index
    if params[:date].present?
      @payroll_records = @company.payroll_records.where(date: params[:date]).includes(:employee)
    else
      if @employee
        @payroll_records = @employee.payroll_records.includes(:employee).all
      else
        @payroll_records = @company.payroll_records.includes(:employee).all
      end
    end

    render json: @payroll_records.as_json(include: :employee)
  end

  # GET /companies/:company_id/employees/:employee_id/payroll_records/:id
  def show
    render json: {
      payroll_record: @payroll_record,
      gross_pay: @payroll_record.gross_pay,
      net_pay: @payroll_record.net_pay,
      withholding_tax: @payroll_record.withholding_tax,
      social_security_tax: @payroll_record.social_security_tax,
      medicare_tax: @payroll_record.medicare_tax,
      retirement_payment: @payroll_record.retirement_payment
    }
  end

  # POST /companies/:company_id/employees/:employee_id/payroll_records
  def create
    @payroll_record = @employee.payroll_records.build(payroll_record_params)
    payroll_calculator = PayrollCalculator.for(@employee, @payroll_record)
    payroll_calculator.calculate

    if @payroll_record.save
      render json: @payroll_record, status: :created, location: company_employee_payroll_record_path(@company, @employee, @payroll_record)
    else
      render json: @payroll_record.errors, status: :unprocessable_entity
    end
  end

  # POST /companies/:company_id/employees/batch/payroll_records
  def batch_create
    payroll_records_params = params.require(:payroll_records).map do |record|
      record.permit(:employee_id, :date, :hours_worked, :overtime_hours_worked, :reported_tips, :loan_payment, :insurance_payment, :gross_pay)
    end

    created_records = payroll_records_params.map do |record_params|
      employee = @company.employees.find_by(id: record_params[:employee_id])
      unless employee
        render json: { error: "Employee with ID #{record_params[:employee_id]} not found in company." }, status: :not_found and return
      end
      payroll_record = employee.payroll_records.new(record_params)
      payroll_calculator = PayrollCalculator.for(employee, payroll_record)
      payroll_calculator.calculate
      payroll_record.save
      payroll_record
    end

    if created_records.all?(&:persisted?)
      render json: created_records.map { |record| record.as_json(include: :employee) }, status: :created
    else
      render json: { errors: created_records.map { |record| record.errors.full_messages } }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/:company_id/employees/:employee_id/payroll_records/:id
  def update
    if @payroll_record.update(payroll_record_params)
      render json: @payroll_record
    else
      render json: @payroll_record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /companies/:company_id/employees/:employee_id/payroll_records/:id
  def destroy
    if @payroll_record.destroy
      render json: { notice: 'Payroll record was successfully destroyed.' }
    else
      render json: { error: 'Error destroying payroll record.' }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions
  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_employee
    if params[:employee_id]
      @employee = @company.employees.find(params[:employee_id])
    end
  end

  def set_payroll_record
    @payroll_record = @employee.payroll_records.find(params[:id])
  end

  def handle_not_found
    render json: { error: 'Record not found.' }, status: :not_found
  end

  # Only allow a list of trusted parameters through
  def payroll_record_params
    params.require(:payroll_record).permit(:date, :gross_pay, :loan_payment, :insurance_payment, :reported_tips, 
      :hours_worked, :overtime_hours_worked).tap do |permitted_params|
      if @employee.department == 'salary'
        permitted_params.delete(:hours_worked)
        permitted_params.delete(:overtime_hours_worked)
      else
        permitted_params.delete(:gross_pay)
      end
    end
  end
end
