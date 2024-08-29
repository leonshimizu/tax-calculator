# app/controllers/files_controller.rb

class FilesController < ApplicationController
  # Make sure to require the file
  require Rails.root.join('lib', 'process_payroll')

  def upload_files
    uploaded_files = params[:files]
    Rails.logger.info "Received files: #{uploaded_files.map(&:original_filename).inspect}"

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

      Rails.logger.info "Processing file: #{file.original_filename}, identified as: #{file_type}"

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
        Rails.logger.error "Invalid file content for file: #{file.original_filename}"
        render json: { error: "Invalid file content: #{file.original_filename}" }, status: :unprocessable_entity
        return
      end
    end

    # Check if all required files are present
    if temp_file_paths.values.any?(&:nil?)
      missing_files = temp_file_paths.select { |key, value| value.nil? }.keys
      Rails.logger.error "Missing one or more required files: #{missing_files.join(', ')}"
      render json: { error: 'Missing one or more required files.' }, status: :unprocessable_entity
      return
    end

    Rails.logger.info "All required files present. Proceeding with processing."

    begin
      master_file_path = ProcessPayroll.process(temp_file_paths.values)
      Rails.logger.info "Successfully processed payroll. Master file generated at: #{master_file_path}"

      # Send the master file to the user for download
      send_file master_file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', filename: 'Master_Payroll_File.xlsx'

      # # Delete the master file after sending it
      # File.delete(master_file_path) if File.exist?(master_file_path)
      # Rails.logger.info "Deleted master file: #{master_file_path}"

      # Clean up temporary files if necessary
      temp_file_paths.values.each do |path|
        if path
          File.delete(path)
          Rails.logger.info "Deleted temporary file: #{path}"
        end
      end

    rescue => e
      Rails.logger.error "General error during file processing: #{e.message}"
      render json: { error: "Failed to process files: #{e.message}" }, status: :unprocessable_entity
    end
  end

  private

  def save_temp_file(file)
    temp_file = Rails.root.join('tmp', file.original_filename)
    File.open(temp_file, 'wb') do |f|
      f.write(file.read)
    end
    Rails.logger.info "Saved file #{file.original_filename} to temporary path: #{temp_file}"
    temp_file.to_s
  end

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
