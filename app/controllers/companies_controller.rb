# app/controllers/companies_controller.rb
class CompaniesController < ApplicationController
  def index
    @companies = Company.all
    render json: @companies
  end

  def show
    @company = Company.find(params[:id])
    render json: @company.as_json(include: :employees)
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
end
