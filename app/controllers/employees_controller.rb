class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  def index
    @employees = Employee.all
  end

  def show
  end

  def new
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)
    if @employee.save
      redirect_to employee_path(@employee), notice: 'Employee was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @employee.update(employee_params)
      redirect_to employee_path(@employee), notice: 'Employee was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @employee.destroy
    redirect_to employees_url, notice: 'Employee was successfully destroyed.'
  end
  
  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def handle_not_found
    redirect_to employees_path, alert: "Employee not found."
  end
  
  def employee_params
    params.require(:employee).permit(:name, :filing_status, :pay_rate, :retirement_rate, :position)
  end
end
