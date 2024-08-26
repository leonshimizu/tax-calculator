# app/controllers/files_controller.rb
class FilesController < ApplicationController
  require 'pycall/import'
  include PyCall::Import

  def upload_files
    uploaded_files = params[:files]
    
    # Initialize variables to store file paths
    temp_file_paths = {
      revel: nil,
      tips_1: nil,
      tips_2: nil,
      loan: nil
    }
    
    uploaded_files.each do |file|
      temp_file_path = save_temp_file(file)
      file_type = identify_file_type(temp_file_path)
      
      case file_type
      when 'revel'
        temp_file_paths[:revel] = temp_file_path
      when 'tips'
        if temp_file_paths[:tips_1].nil?
          temp_file_paths[:tips_1] = temp_file_path
        else
          temp_file_paths[:tips_2] = temp_file_path
        end
      when 'loan'
        temp_file_paths[:loan] = temp_file_path
      else
        render json: { error: "Invalid file content: #{file.original_filename}" }, status: :unprocessable_entity
        return
      end
    end
    
    # Check if all required files are present
    if temp_file_paths.values.any?(&:nil?)
      render json: { error: 'Missing one or more required files.' }, status: :unprocessable_entity
      return
    end
    
    # Ensure Python path includes your script location
    PyCall.exec("import sys; sys.path.append('/Users/leonshimizu/Desktop/TaxBusiness/tax-calculator/lib/python_scripts/')")

    # Proceed with processing the files using the Python script
    pyimport 'process_payroll'
    master_file_path = process_payroll.process_payroll(temp_file_paths.values)

    # Send the master file to the user for download
    send_file master_file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', filename: 'Master_Payroll_File.xlsx'

    # Clean up temporary files if necessary
    temp_file_paths.values.each { |path| File.delete(path) if path }

  rescue => e
    render json: { error: "Failed to process files: #{e.message}" }, status: :unprocessable_entity
  end

  private

  # Helper method to save uploaded files temporarily
  def save_temp_file(file)
    temp_file = Rails.root.join('tmp', file.original_filename)
    File.open(temp_file, 'wb') do |f|
      f.write(file.read)
    end
    temp_file.to_s
  end

  # Helper method to determine file type by reading its content
  def identify_file_type(file_path)
    xlsx = Roo::Excelx.new(file_path)
    headers = xlsx.row(1)

    if headers.include?('hours_worked') && headers.include?('overtime_hours_worked')
      'revel'
    elsif headers.include?('reported_tips')
      'tips'
    elsif headers.include?('loan_payment')
      'loan'
    else
      nil
    end
  end
end
