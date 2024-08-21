# app/controllers/companies_controller.rb
class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :update, :destroy]

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
    @company.destroy
  end

  def department_ytd_totals
    company = Company.find(params[:id])
    department = params[:department]
    year = params[:year].to_i || Time.current.year
    render json: company.department_ytd_totals(department, year)
  end

  def company_ytd_totals
    company = Company.find(params[:id])
    year = params[:year].to_i || Time.current.year
    render json: company.company_ytd_totals(year)
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :address, :phone_number, :email) # Adjust the permitted parameters as needed
  end
end
