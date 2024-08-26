# app/controllers/employees_controller.rb
class EmployeesController < ApplicationController
  before_action :set_company
  before_action :set_employee, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  def index
    employees = @company.employees.all
    render json: employees
  end

  def show
    render json: @employee
  end

  def create
    employee = @company.employees.build(employee_params)
    if employee.save
      render json: employee, status: :created
    else
      render json: employee.errors, status: :unprocessable_entity
    end
  end

  def update
    if @employee.update(employee_params)
      render json: @employee
    else
      render json: @employee.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @employee.destroy
      render json: { notice: 'Employee was successfully destroyed.' }
    else
      render json: { error: 'Error destroying employee.' }, status: :unprocessable_entity
    end
  end

  def ytd_totals
    employee = Employee.find(params[:id])
    year = params[:year].presence || Time.current.year
    render json: employee.ytd_totals(year.to_i)
  end

  def upload
    employees_data = params[:employees]

    employees_data.each do |employee_data|
      # Convert ActionController::Parameters to a permitted hash
      permitted_data = employee_data.permit(
        :first_name, :last_name, :payroll_type, :department, :pay_rate,
        :retirement_rate, :roth_retirement_rate, :filing_status
      ).to_h

      # Adjust the retirement_rate if necessary
      permitted_data[:retirement_rate] = adjust_retirement_rate(permitted_data[:retirement_rate])
      permitted_data[:roth_retirement_rate] = adjust_retirement_rate(permitted_data[:roth_retirement_rate]) if permitted_data[:roth_retirement_rate]
  
      # Find or initialize an employee by first and last name
      employee = @company.employees.find_or_initialize_by(
        first_name: permitted_data[:first_name],
        last_name: permitted_data[:last_name]
      )

      # Check if the existing employee needs an update
      if employee.new_record? || attributes_need_update?(employee, permitted_data)
        employee.assign_attributes(permitted_data)

        unless employee.save
          Rails.logger.error "Failed to save employee #{employee.first_name} #{employee.last_name}: #{employee.errors.full_messages.join(', ')}"
        end
      end
    end
  
    render json: { message: 'Employees uploaded successfully' }, status: :ok
  rescue StandardError => e
    Rails.logger.error "Error uploading employees: #{e.message}"
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private
  
  def adjust_retirement_rate(rate)
    rate = rate.to_f
    if rate > 0 && rate < 1
      rate * 100  # Convert decimal to percentage
    else
      rate
    end
  end

  def attributes_need_update?(employee, permitted_data)
    # Convert permitted_data to a hash before comparing
    permitted_data.to_h.any? do |key, value|
      employee[key] != value
    end
  end

  def set_company
    @company = Company.find(params[:company_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Company not found.' }, status: :not_found
  end

  def set_employee
    @employee = @company.employees.find(params[:employee_id] || params[:id])
  end

  def handle_not_found
    render json: { error: 'Employee not found.' }, status: :not_found
  end

  def employee_params
    params.require(:employee).permit(
      :id, 
      :filing_status, 
      :pay_rate, 
      :retirement_rate, 
      :department, 
      :first_name, 
      :last_name, 
      :company_id, 
      :payroll_type, 
      :roth_retirement_rate
    )
  end

  def required_fields_missing?(data)
    data[:first_name].blank? || data[:last_name].blank? ||
    data[:payroll_type].blank? || data[:department].blank? ||
    data[:pay_rate].blank?
  end
end
