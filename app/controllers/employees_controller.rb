# app/controllers/employees_controller.rb
class EmployeesController < ApplicationController
  before_action :set_company
  before_action :set_employee, only: [:show, :update, :destroy, :ytd_totals]
  # Skip setting a specific employee, as this is a collection route
  skip_before_action :set_employee, only: [:ytd_totals]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  def index
    employees = @company.employees.includes(:department).all
    render json: employees, include: :department
  end

  def show
    render json: @employee, include: :department
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
    @employees = @company.employees.map do |employee|
      employee.calculate_ytd_totals(params[:year].to_i)
      employee_ytd_totals = employee.employee_ytd_totals.find_by(year: params[:year])
  
      employee_data = {
        first_name: employee.first_name,
        last_name: employee.last_name,
        hours_worked: employee_ytd_totals&.hours_worked || 0,
        overtime_hours_worked: employee_ytd_totals&.overtime_hours_worked || 0,
        gross_pay: employee_ytd_totals&.gross_pay || 0,
        net_pay: employee_ytd_totals&.net_pay || 0,
        withholding_tax: employee_ytd_totals&.withholding_tax || 0,
        social_security_tax: employee_ytd_totals&.social_security_tax || 0,
        medicare_tax: employee_ytd_totals&.medicare_tax || 0,
        retirement_payment: employee_ytd_totals&.retirement_payment || 0,
        roth_retirement_payment: employee_ytd_totals&.roth_retirement_payment || 0,
        bonus: employee_ytd_totals&.bonus || 0,
        total_deductions: employee_ytd_totals&.total_deductions || 0
      }
  
      Rails.logger.info(employee_data)  # Debugging log
      employee_data
    end
  
    render json: @employees
  end

  def upload
    employees_data = params[:employees]

    employees_data.each do |employee_data|
      permitted_data = employee_data.permit(
        :first_name, :last_name, :payroll_type, :department, :department_id, :pay_rate,
        :retirement_rate, :roth_retirement_rate, :filing_status
      ).to_h

      permitted_data[:retirement_rate] = adjust_retirement_rate(permitted_data[:retirement_rate])
      permitted_data[:roth_retirement_rate] = adjust_retirement_rate(permitted_data[:roth_retirement_rate]) if permitted_data[:roth_retirement_rate]

      department = if permitted_data[:department_id]
                     @company.departments.find(permitted_data[:department_id])
                   else
                     @company.departments.find_by(name: permitted_data[:department])
                   end

      unless department
        Rails.logger.error "Department not found for employee #{permitted_data[:first_name]} #{permitted_data[:last_name]}."
        next
      end

      employee = @company.employees.find_or_initialize_by(
        first_name: permitted_data[:first_name],
        last_name: permitted_data[:last_name]
      )

      employee.assign_attributes(permitted_data.except(:department, :department_id))
      employee.department = department

      if employee.new_record? || attributes_need_update?(employee, permitted_data)
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
    rate > 0 && rate < 1 ? rate * 100 : rate
  end

  def attributes_need_update?(employee, permitted_data)
    permitted_data.to_h.any? { |key, value| employee[key] != value }
  end

  def set_company
    @company = Company.find(params[:company_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Company not found.' }, status: :not_found
  end

  def set_employee
    @employee = @company.employees.find(params[:id])
    if @employee.nil?
      render json: { error: 'Employee not found' }, status: :not_found
    end
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
      :department_id,  
      :first_name, 
      :last_name, 
      :company_id, 
      :payroll_type, 
      :roth_retirement_rate
    )
  end
end
