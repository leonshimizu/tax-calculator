class DepartmentsController < ApplicationController
  before_action :set_company
  before_action :set_department, only: [:show, :update, :destroy]

  # GET /companies/:company_id/departments
  def index
    @departments = @company.departments
    render json: @departments
  end

  # GET /companies/:company_id/departments/:id
  def show
    render json: @department
  end

  # POST /companies/:company_id/departments
  def create
    @department = @company.departments.new(department_params)
    if @department.save
      render json: @department, status: :created
    else
      render json: { errors: @department.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/:company_id/departments/:id
  def update
    if @department.update(department_params)
      render json: @department, status: :ok
    else
      render json: { errors: @department.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /companies/:company_id/departments/:id
  def destroy
    if @department.destroy
      render json: { message: 'Department was successfully deleted.' }, status: :ok
    else
      render json: { error: 'Error deleting department.' }, status: :unprocessable_entity
    end
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_department
    @department = @company.departments.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name)
  end
end
