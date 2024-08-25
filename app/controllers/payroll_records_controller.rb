# app/controllers/payroll_records_controller.rb
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
      total_deductions: @payroll_record.total_deductions,
      custom_columns: @payroll_record.custom_columns_data
    }
  end

  # POST /companies/:company_id/employees/:employee_id/payroll_records
  def create
    @payroll_record = @employee.payroll_records.new(payroll_record_params)

    # Extract custom columns from params and assign to custom_columns_data
    custom_columns = @company.custom_columns.pluck(:name)
    # Ensure custom_columns_data is permitted as a hash of arbitrary keys/values
    custom_data = params.require(:payroll_record).fetch(:custom_columns_data, {}).permit(custom_columns.map(&:to_sym))
    @payroll_record.custom_columns_data = custom_data.to_h # Convert permitted parameters to hash

    Rails.logger.debug "PayrollRecord Params: #{payroll_record_params.inspect}"
    Rails.logger.debug "Before Save - Roth Retirement Payment: #{@payroll_record.roth_retirement_payment.inspect}"
    Rails.logger.debug "Custom Columns Data: #{custom_data.inspect}"

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
    @company = Company.find(params[:company_id])
    @payroll_records = []
  
    ActiveRecord::Base.transaction do
      params[:payroll_records].each do |record_params|
        employee = @company.employees.find(record_params[:employee_id])
        payroll_record_params = record_params.permit(
          :employee_id,
          :date,
          :hours_worked,
          :overtime_hours_worked,
          :reported_tips,
          :loan_payment,
          :insurance_payment,
          :gross_pay,
          :bonus,
          :retirement_payment,
          :roth_retirement_payment,
          custom_columns_data: {} # Permit the custom columns data here
        )
        
        payroll_record = PayrollRecord.new(payroll_record_params)
        payroll_record.employee = employee
  
        if payroll_record.save
          @payroll_records << payroll_record
        else
          raise ActiveRecord::Rollback # Rollback transaction if any record fails to save
        end
      end
    end
  
    if @payroll_records.any?
      render json: @payroll_records, status: :created
    else
      render json: { error: 'Failed to create payroll records' }, status: :unprocessable_entity
    end
  end
  

  # PATCH/PUT /companies/:company_id/employees/:employee_id/payroll_records/:id
  def update
    custom_columns_data = {}
    @company.custom_columns.each do |column|
      custom_columns_data[column.name] = params[:payroll_record][column.name] if params[:payroll_record][column.name]
    end

    if @payroll_record.update(processed_payroll_record_params.merge(custom_columns_data: custom_columns_data))
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

  def upload
    payroll_data = params[:payroll_data]

    payroll_data.each do |entry|
      first_name = entry['first_name']
      last_name = entry['last_name']
      
      employee = @company.employees.find_by(first_name: first_name, last_name: last_name)

      if employee
        # Check payroll_type and create a PayrollRecord accordingly
        if employee.payroll_type == 'hourly'
          create_hourly_payroll_record(employee, entry)
        elsif employee.payroll_type == 'salary'
          create_salary_payroll_record(employee, entry)
        else
          Rails.logger.error "Unknown payroll type for employee #{employee.full_name}"
        end
      else
        Rails.logger.error "Employee #{first_name} #{last_name} not found."
      end
    end

    render json: { message: 'Payroll records uploaded successfully' }, status: :ok
  rescue StandardError => e
    Rails.logger.error "Error uploading payroll records: #{e.message}"
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def create_hourly_payroll_record(employee, entry)
    payroll_record = employee.payroll_records.new(
      date: Date.today,
      hours_worked: entry['hours_worked'],
      overtime_hours_worked: entry['overtime_hours_worked'],
      reported_tips: entry['reported_tips'],
      loan_payment: entry['loan_payment'],
      insurance_payment: entry['insurance_payment']
    )
    
    unless payroll_record.save
      Rails.logger.error "Failed to save payroll record for employee #{employee.full_name}: #{payroll_record.errors.full_messages.join(', ')}"
    end
  end

  def create_salary_payroll_record(employee, entry)
    payroll_record = employee.payroll_records.new(
      date: Date.today,
      gross_pay: entry['gross_pay'],
      bonus: entry['bonus'],
      loan_payment: entry['loan_payment'],
      insurance_payment: entry['insurance_payment'],
      retirement_payment: entry['retirement_payment']
    )
    
    unless payroll_record.save
      Rails.logger.error "Failed to save payroll record for employee #{employee.full_name}: #{payroll_record.errors.full_messages.join(', ')}"
    end
  end

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
    params.require(:payroll_record).permit(
      :employee_id,
      :date,
      :hours_worked,
      :overtime_hours_worked,
      :reported_tips,
      :loan_payment,
      :insurance_payment,
      :gross_pay,
      :bonus,
      :retirement_payment,
      :roth_retirement_payment,
      custom_columns_data: {} # Permit custom_columns_data as a hash
    )
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
