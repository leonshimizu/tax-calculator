class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :update, :destroy, :company_ytd_totals, :update_ytd_totals]

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

  # GET /companies/:id/company_ytd_totals
  def company_ytd_totals
    year = params[:year].presence || Time.current.year
    totals = @company.calculate_ytd_totals(year.to_i)
    render json: totals
  end

  # POST /companies/:id/update_ytd_totals
  def update_ytd_totals
    year = params[:year]

    if year.blank?
      render json: { error: 'Year parameter is missing.' }, status: :bad_request and return
    end

    begin
      @company.calculate_company_ytd_totals(year.to_i)
      render json: { message: 'YTD totals updated successfully' }, status: :ok
    rescue StandardError => e
      render json: { error: 'Failed to update YTD totals' }, status: :unprocessable_entity
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Company not found.' }, status: :not_found
  end

  def company_params
    params.require(:company).permit(:name)
  end
end
