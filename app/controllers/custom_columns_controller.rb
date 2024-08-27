# app/controllers/custom_columns_controller.rb
class CustomColumnsController < ApplicationController
  before_action :set_company
  before_action :set_custom_column, only: [:update, :destroy]

  def index
    @custom_columns = @company.custom_columns
    render json: @custom_columns
  end

  def create
    @custom_column = @company.custom_columns.build(custom_column_params)

    if @custom_column.save
      render json: @custom_column, status: :created
    else
      render json: @custom_column.errors, status: :unprocessable_entity
    end
  end

  def update
    if @custom_column.update(custom_column_params)
      render json: @custom_column
    else
      render json: @custom_column.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @custom_column.destroy
      head :no_content
    else
      render json: { error: 'Failed to delete custom column' }, status: :unprocessable_entity
    end
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_custom_column
    @custom_column = @company.custom_columns.find(params[:id])
  end

  def custom_column_params
    params.require(:custom_column).permit(:name, :data_type, :include_in_payroll, :is_deduction)
  end
end
