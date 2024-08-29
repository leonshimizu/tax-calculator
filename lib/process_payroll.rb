# lib/process_payroll.rb

require 'roo'
require 'caxlsx'

module ProcessPayroll
  def self.process(files)
    # Load each Excel file using Roo
    revel_xlsx = Roo::Excelx.new(files[0])
    tips1_xlsx = Roo::Excelx.new(files[1])
    tips2_xlsx = Roo::Excelx.new(files[2])
    loan_xlsx = Roo::Excelx.new(files[3])

    # Convert to arrays of hashes for easier manipulation
    revel_data = revel_xlsx.sheet(0).parse(headers: true).drop(1) # Skip header row
    tips1_data = tips1_xlsx.sheet(0).parse(headers: true).drop(1) # Skip header row
    tips2_data = tips2_xlsx.sheet(0).parse(headers: true).drop(1) # Skip header row
    loan_data = loan_xlsx.sheet(0).parse(headers: true).drop(1)   # Skip header row

    # Process Revel data to handle full names
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

    # Initialize a hash to store processed data
    processed_data = []

    # Merge tips data with Revel data based on first and last name
    revel_data.each do |row|
      first_name = row['first_name']
      last_name = row['last_name']

      tips1 = tips1_data.find { |t| t['first_name'] == first_name && t['last_name'] == last_name }&.fetch('reported_tips', 0).to_f
      tips2 = tips2_data.find { |t| t['first_name'] == first_name && t['last_name'] == last_name }&.fetch('reported_tips', 0).to_f
      row['total_reported_tips'] = tips1 + tips2

      loan = loan_data.find { |l| l['first_name'] == first_name && l['last_name'] == last_name }&.fetch('loan_payment', 0).to_f
      row['loan_payment'] = loan

      processed_data << row
    end

    # Debugging: Print processed data to console and flush immediately
    puts "Processed data before writing to Excel: #{processed_data.inspect}"
    $stdout.flush  # Ensure output is flushed immediately

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
    # Remove any leading/trailing whitespace and split by comma
    name_parts = full_name.strip.split(',')

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
end
