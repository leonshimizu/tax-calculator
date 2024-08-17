Rails.application.routes.draw do
  get 'calculate', to: 'tax_calculator#calculate'
  get 'payroll/show', to: 'payroll#show'

  # Set the root to the payroll show action
  root 'payroll#show'

  resources :employees do
    resources :payroll_records, only: [:create, :update]
  end
end
