class EmployeesController < ApplicationController
  def index
    @employees = Employee.all
  end

  def show
    @employee = Employee.find(params[:id])
  end

  # incomplete - still need to add the data to what's created
  def new
    @employee = Employee.new
  end

  # incomplete - still need to add the data to what's edited
  def edit
    @employee = Employee.find(params[:id])
  end

  def destroy
    @employee = Employee.find(params[:id])
    @employee.destroy
    # redirect_to employees_url, notice: 'Employee was successfully destroyed.'
  end
  
  private
  def employee_params
    params.require(:employee).permit(:name, :filing_status, :pay_rate, :401k_rate, :position)
  end
end
