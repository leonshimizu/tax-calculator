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
end
