# app/services/withholding_tax_calculator.rb
class WithholdingTaxCalculator
  TAX_TABLE = [
    { min_income: 0, max_income: 561.99, base_tax: 0.00, rate: 0.00, threshold: 0 },
    { min_income: 562, max_income: 1007.99, base_tax: 0.00, rate: 0.10, threshold: 562 },
    { min_income: 1008, max_income: 2374.99, base_tax: 44.60, rate: 0.12, threshold: 1008 },
    { min_income: 2375, max_income: 4427.99, base_tax: 208.64, rate: 0.22, threshold: 2375 },
    { min_income: 4428, max_income: 7943.99, base_tax: 660.30, rate: 0.24, threshold: 4428 },
    { min_income: 7944, max_income: 9935.99, base_tax: 1504.14, rate: 0.32, threshold: 7944 },
    { min_income: 9936, max_income: 23997.99, base_tax: 2141.58, rate: 0.35, threshold: 9936 },
    { min_income: 23998, max_income: Float::INFINITY, base_tax: 7063.28, rate: 0.37, threshold: 23998 }
  ]

  def self.calculate(gross_income)
    bracket = TAX_TABLE.find do |row|
      gross_income >= row[:min_income] && gross_income <= row[:max_income]
    end

    if bracket
      tax = (gross_income - bracket[:threshold]) * bracket[:rate] + bracket[:base_tax]
      tax.round(2)
    else
      0.00
    end
  end
end
