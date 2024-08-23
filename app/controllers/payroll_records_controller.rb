class PayrollRecordsController < ApplicationController
  before_action :set_company
  before_action :set_employee, except: :batch_create
  before_action :set_payroll_record, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  # GET /companies/:company_id/employees/:employee_id/payroll_records
  # GET /companies/:company_id/payroll_records
  def index
    @payroll_records = if params[:date].present?
                         @company.payroll_records.where(date: params[:date]).includes(:employee)
                       elsif @employee
                         @employee.payroll_records.includes(:employee).all
                       else
                         @company.payroll_records.includes(:employee).all
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
      retirement_payment: @payroll_record.retirement_payment,
      roth_retirement_payment: @payroll_record.roth_retirement_payment,
      total_deductions: @payroll_record.total_deductions
    }
  end

  # POST /companies/:company_id/employees/:employee_id/payroll_records
  def create
    @payroll_record = @employee.payroll_records.new(payroll_record_params)

    Rails.logger.debug "PayrollRecord Params: #{payroll_record_params.inspect}"
    Rails.logger.debug "Before Save - Roth Retirement Payment: #{@payroll_record.roth_retirement_payment.inspect}"

    if @payroll_record.save
      Rails.logger.debug "After Save - Roth Retirement Payment: #{@payroll_record.roth_retirement_payment.inspect}"
      redirect_to [@company, @employee], notice: 'Payroll record was successfully created.'
    else
      Rails.logger.error "Payroll Record Save Failed: #{@payroll_record.errors.full_messages.inspect}"
      render :new
    end
  end

  # POST /companies/:company_id/employees/batch/payroll_records
  def batch_create
    payroll_records_params = params.require(:payroll_records).map do |record|
      record.permit(:employee_id, :date, :hours_worked, :overtime_hours_worked, :reported_tips, :loan_payment, :insurance_payment, :gross_pay, :bonus, :retirement_payment, :roth_retirement_payment)
    end

    created_records = payroll_records_params.map do |record_params|
      employee = @company.employees.find_by(id: record_params[:employee_id])
      unless employee
        render json: { error: "Employee with ID #{record_params[:employee_id]} not found in company." }, status: :not_found and return
      end
      payroll_record = employee.payroll_records.new(process_payroll_record_params(record_params, employee))
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
    if @payroll_record.update(processed_payroll_record_params)
      Rails.logger.debug "Updated PayrollRecord: #{@payroll_record.inspect}"
      render json: @payroll_record
    else
      Rails.logger.error "Payroll Record Update Failed: #{@payroll_record.errors.full_messages.inspect}"
      render json: @payroll_record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /companies/:company_id/employees/:employee_id/payroll_records/:id
  def destroy
    if @payroll_record.destroy
      render json: { notice: 'Payroll record was successfully destroyed.' }
    else
      Rails.logger.error "Payroll Record Destroy Failed: #{@payroll_record.errors.full_messages.inspect}"
      render json: { error: 'Error destroying payroll record.' }, status: :unprocessable_entity
    end
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_employee
    @employee = @company.employees.find(params[:employee_id]) if params[:employee_id]
  end

  def set_payroll_record
    @payroll_record = @employee.payroll_records.find(params[:id])
  end

  def handle_not_found
    render json: { error: 'Record not found.' }, status: :not_found
  end

  def payroll_record_params
    params.require(:payroll_record).permit(:hours_worked, :overtime_hours_worked, :reported_tips, :loan_payment, :insurance_payment, :date, :gross_pay, :bonus, :retirement_payment, :roth_retirement_payment)
  end

  def processed_payroll_record_params
    process_payroll_record_params(payroll_record_params, @employee)
  end

  def process_payroll_record_params(params, employee)
    params = params.dup
    if employee.payroll_type == 'salary'
      params[:gross_pay] = params[:gross_pay].to_f if params[:gross_pay].present?
      params.delete(:hours_worked)
      params.delete(:overtime_hours_worked)
    else
      params[:hours_worked] = params[:hours_worked].to_f if params[:hours_worked].present?
      params[:overtime_hours_worked] = params[:overtime_hours_worked].to_f if params[:overtime_hours_worked].present?
      params.delete(:gross_pay)
    end

    # Ensure roth_retirement_payment is processed properly if explicitly set
    params[:roth_retirement_payment] = params[:roth_retirement_payment].to_f if params[:roth_retirement_payment].present?

    params
  end
end
