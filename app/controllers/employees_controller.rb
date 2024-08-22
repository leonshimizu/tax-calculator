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
    params.require(:employee).permit(:first_name, :last_name, :payroll_type, :department, :pay_rate, :gross_pay, :retirement_rate, :filing_status, :company_id)
  end
end
