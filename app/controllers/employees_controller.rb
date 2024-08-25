# app/controllers/employees_controller.rb
class EmployeesController < ApplicationController
  before_action :set_company
  before_action :set_employee, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  def index
    @employees = @company.employees.all
    render json: @employees
  end

  def show
    render json: @employee
  end

  def create
    @employee = @company.employees.build(employee_params)
    if @employee.save
      render json: @employee, status: :created
    else
      render json: @employee.errors, status: :unprocessable_entity
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
    year = params[:year].to_i || Time.current.year
    render json: employee.ytd_totals(year)
  end

  def upload
    employees_data = params[:employees]
  
    employees_data.each do |employee_data|
      # Skip any employee data that has missing required fields
      next if employee_data['first_name'].blank? || employee_data['last_name'].blank? || employee_data['payroll_type'].blank? || employee_data['department'].blank? || employee_data['pay_rate'].blank?
  
      # Initialize employee without finding by ID since new employees will not have an ID
      employee = @company.employees.find_or_initialize_by(
        first_name: employee_data['first_name'], 
        last_name: employee_data['last_name']
      )
  
      # Assign attributes excluding any key that doesn't match the model attributes
      employee.assign_attributes(employee_data.slice(*employee_params.keys))
  
      # Save employee if valid, else log the error
      if employee.save
        Rails.logger.info "Employee #{employee.first_name} #{employee.last_name} saved successfully."
      else
        Rails.logger.error "Failed to save employee: #{employee.errors.full_messages.join(', ')}"
      end
    end
  
    render json: { message: 'Employees uploaded successfully' }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_employee
    @employee = @company.employees.find_by(id: params[:employee_id] || params[:id])
    unless @employee
      render json: { error: 'Employee not found.' }, status: :not_found
    end
  end

  def handle_not_found
    render json: { error: 'Employee not found.' }, status: :not_found
  end

  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :pay_rate, :retirement_rate, :department, :filing_status, :payroll_type, :roth_retirement_rate, :company_id)
  end  
end
