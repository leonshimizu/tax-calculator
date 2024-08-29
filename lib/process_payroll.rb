# lib/process_payroll.rb

require 'roo'
require 'caxlsx'

module ProcessPayroll
  def self.process(revel_file, combined_file)
    # Load each Excel file using Roo
    revel_xlsx = Roo::Excelx.new(revel_file)
    combined_xlsx = Roo::Excelx.new(combined_file) # Assuming tips and loan are in this file

    # Convert Revel data to an array of hashes for easier manipulation
    revel_data = revel_xlsx.sheet(0).parse(headers: true).drop(1) # Skip header row

    # Initialize arrays to store parsed data from different sheets
    tips1_data = []
    tips2_data = []
    loan_data = []

    # Loop through each sheet in the combined file and categorize the data
    combined_xlsx.sheets.each do |sheet_name|
      sheet = combined_xlsx.sheet(sheet_name)
      data = sheet.parse(headers: true).drop(1) # Skip header row

      Rails.logger.info "Processing sheet: #{sheet_name} with headers: #{data.first.keys}"

      if data.any? { |row| row.key?('reported_tips') }
        if tips1_data.empty?
          tips1_data = data
        else
          tips2_data = data
        end
      elsif data.any? { |row| row.key?('loan_payment') }
        loan_data = data
      end
    end

    # Process Revel data to handle full names and remove periods
    revel_data = revel_data.map do |row|
      if row.key?('full_name')
        if row['full_name'].nil?
          Rails.logger.error "Row with missing full_name detected: #{row.inspect}"
          next # Skip processing this row
        else
          names = split_full_name(row['full_name'])
          row['first_name'] = names[:first_name]
          row['last_name'] = names[:last_name]
        end
      end
      row.slice('first_name', 'last_name', 'hours_worked', 'overtime_hours_worked')
    end.compact  # Remove any rows that were skipped

    # Remove periods from tips and loans data
    tips1_data = remove_periods_from_names(tips1_data)
    tips2_data = remove_periods_from_names(tips2_data)
    loan_data = remove_periods_from_names(loan_data)

    # Initialize a hash to store processed data
    processed_data = []

    # Merge tips data with Revel data based on first and last name
    revel_data.each do |row|
      first_name = row['first_name']
      last_name = row['last_name']

      tips1 = tips1_data.find { |t| t['first_name'] == first_name && t['last_name'] == last_name }&.fetch('reported_tips', 0).to_f
      tips2 = tips2_data.find { |t| t['first_name'] == first_name && t['last_name'] == last_name }&.fetch('reported_tips', 0).to_f
      row['reported_tips'] = tips1 + tips2

      loan = loan_data.find { |l| l['first_name'] == first_name && l['last_name'] == last_name }&.fetch('loan_payment', 0).to_f
      row['loan_payment'] = loan

      processed_data << row
    end

    # Create a new Excel file with the processed data
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: "Master Payroll") do |sheet|
        # Add headers once
        sheet.add_row processed_data.first.keys if processed_data.any?

        # Add data rows
        processed_data.each do |row|
          sheet.add_row row.values
        end
      end
      p.serialize('master_payroll_file.xlsx')
    end

    'master_payroll_file.xlsx'
  end

  private

  # Helper method to split full name into first, middle, and last names
  def self.split_full_name(full_name)
    # Remove any leading/trailing whitespace, periods, and split by comma
    full_name = full_name.to_s.gsub('.', '').strip # Ensure full_name is a string before gsub
    name_parts = full_name.split(',')

    last_name = name_parts[0].strip if name_parts[0] # Get last name from the first part, trimming spaces

    # Handle first and middle names if present
    if name_parts[1]
      first_and_middle_names = name_parts[1].strip.split(' ')
      first_name = first_and_middle_names.shift # Get the first name
      first_name += " #{first_and_middle_names.join(' ')}" if first_and_middle_names.any? # Include middle names if present
    else
      first_name = '' # Default to an empty string if no first name part is available
    end

    { first_name: first_name, last_name: last_name }
  end

  # Helper method to remove periods from first_name and last_name fields in a dataset
  def self.remove_periods_from_names(data)
    data.each do |row|
      row['first_name'] = row['first_name'].to_s.gsub('.', '') if row.key?('first_name') && row['first_name']
      row['last_name'] = row['last_name'].to_s.gsub('.', '') if row.key?('last_name') && row['last_name']
    end
  end
end
