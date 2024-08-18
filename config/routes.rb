Rails.application.routes.draw do
  get 'calculate', to: 'tax_calculator#calculate'
  get 'net_pay/show', to: 'net_pay#show'

  # Set the root to the payroll show action
  root 'net_pay#show'

  resources :employees do
    resources :payroll_records
  end
end
