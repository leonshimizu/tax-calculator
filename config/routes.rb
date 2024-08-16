Rails.application.routes.draw do
  get 'calculate', to: 'tax_calculator#calculate'
  get 'payroll/show', to: 'payroll#show'

  # Set the root to the payroll show action
  root 'payroll#show'
end
