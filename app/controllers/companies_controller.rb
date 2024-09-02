class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :update, :destroy, :department_ytd_totals, :company_ytd_totals]

  # GET /companies
  def index
    @companies = Company.all
    render json: @companies
  end

  # GET /companies/:id
  def show
    render json: @company
  end

  # POST /companies
  def create
    @company = Company.new(company_params)

    if @company.save
      render json: @company, status: :created
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/:id
  def update
    if @company.update(company_params)
      render json: @company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # DELETE /companies/:id
  def destroy
    if @company.destroy
      render json: { notice: 'Company was successfully destroyed.' }, status: :ok
    else
      render json: { error: 'Error destroying company.' }, status: :unprocessable_entity
    end
  end

  # GET /companies/:id/department_ytd_totals
  def department_ytd_totals
    department_id = params[:department_id]
    year = params[:year].presence || Time.current.year

    department = @company.departments.find_by(id: department_id)
    
    if department
      render json: @company.department_ytd_totals(department, year.to_i)
    else
      render json: { error: 'Department not found.' }, status: :not_found
    end
  end

  # GET /companies/:id/company_ytd_totals
  def company_ytd_totals
    year = params[:year].presence || Time.current.year
    render json: @company.company_ytd_totals(year.to_i)
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name)
  end
end
