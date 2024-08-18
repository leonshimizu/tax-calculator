# app/services/calculator.rb
class Calculator 
  TAX_TABLES = {
    single: [
      { min_income: 0, max_income: 561.99, base_tax: 0.00, rate: 0.00, threshold: 0 },
      { min_income: 562, max_income: 1007.99, base_tax: 0.00, rate: 0.10, threshold: 562 },
      { min_income: 1008, max_income: 2374.99, base_tax: 44.60, rate: 0.12, threshold: 1008 },
      { min_income: 2375, max_income: 4427.99, base_tax: 208.64, rate: 0.22, threshold: 2375 },
      { min_income: 4428, max_income: 7943.99, base_tax: 660.30, rate: 0.24, threshold: 4428 },
      { min_income: 7944, max_income: 9935.99, base_tax: 1504.14, rate: 0.32, threshold: 7944 },
      { min_income: 9936, max_income: 23997.99, base_tax: 2141.58, rate: 0.35, threshold: 9936 },
      { min_income: 23998, max_income: Float::INFINITY, base_tax: 7063.28, rate: 0.37, threshold: 23998 }
    ],
    married: [
      { min_income: 0, max_income: 1122.99, base_tax: 0.00, rate: 0.00, threshold: 0 },
      { min_income: 1123, max_income: 2014.99, base_tax: 0.00, rate: 0.10, threshold: 1123 },
      { min_income: 2015, max_income: 4749.99, base_tax: 89.20, rate: 0.12, threshold: 2015 },
      { min_income: 4750, max_income: 8855.99, base_tax: 417.40, rate: 0.22, threshold: 4750 },
      { min_income: 8856, max_income: 15887.99, base_tax: 1320.72, rate: 0.24, threshold: 8856 },
      { min_income: 15888, max_income: 19870.99, base_tax: 3008.40, rate: 0.32, threshold: 15888 },
      { min_income: 19871, max_income: 29245.99, base_tax: 4282.96, rate: 0.35, threshold: 19871 },
      { min_income: 29246, max_income: Float::INFINITY, base_tax: 7564.21, rate: 0.37, threshold: 29246 }
    ],
    head_of_household: [
      { min_income: 0, max_income: 841.99, base_tax: 0.00, rate: 0.00, threshold: 0 },
      { min_income: 842, max_income: 1478.99, base_tax: 0.00, rate: 0.10, threshold: 842 },
      { min_income: 1479, max_income: 3268.99, base_tax: 63.70, rate: 0.12, threshold: 1479 },
      { min_income: 3269, max_income: 4707.99, base_tax: 278.50, rate: 0.22, threshold: 3269 },
      { min_income: 4708, max_income: 8224.99, base_tax: 595.08, rate: 0.24, threshold: 4708 },
      { min_income: 8225, max_income: 10214.99, base_tax: 1439.16, rate: 0.32, threshold: 8225 },
      { min_income: 10215, max_income: 24278.99, base_tax: 2075.96, rate: 0.35, threshold: 10215 },
      { min_income: 24279, max_income: Float::INFINITY, base_tax: 6998.36, rate: 0.37, threshold: 24279 }
    ]
  }

  def self.calculate_withholding(gross_pay, filing_status)
    # Select the tax table based on the filing status
    tax_table = TAX_TABLES[filing_status.to_sym]

    # Find the applicable tax bracket
    bracket = tax_table.find do |row|
      gross_pay >= row[:min_income] && gross_pay <= row[:max_income]
    end

    # Calculate the withholding tax based on the bracket
    if bracket
      tax = (gross_pay - bracket[:threshold]) * bracket[:rate] + bracket[:base_tax]
      tax.round(2)
    else
      0.00
    end
  end
  
  def self.calculate_social_security(gross_pay)
    tax = gross_pay * 0.062
    tax.round(2)
  end
  
  def self.calculate_medicare(gross_pay)
    tax = gross_pay * 0.0145
    tax.round(2)
  end
end
