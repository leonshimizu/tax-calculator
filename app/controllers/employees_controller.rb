class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  def index
    @employees = Employee.all
    render json: @employees
  end

  def show
    render json: @employee
  end

  def create
    @employee = Employee.new(employee_params)
    if @employee.save
      render json: @employee, status: :created, location: @employee
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
  
  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def handle_not_found
    render json: { error: 'Employee not found.' }, status: :not_found
  end
  
  def employee_params
    params.require(:employee).permit(:name, :filing_status, :pay_rate, :retirement_rate, :position)
  end
end
