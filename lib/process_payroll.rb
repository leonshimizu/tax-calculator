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

    # Keep only necessary columns from Revel data
    revel_data = revel_data.map do |row|
      row.slice('first_name', 'last_name', 'hours_worked', 'overtime_hours_worked')
    end

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
end
