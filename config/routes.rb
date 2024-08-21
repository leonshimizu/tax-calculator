# config/routes.rb
Rails.application.routes.draw do
  # Define a separate route for batch processing
  post 'employees/batch/payroll_records', to: 'payroll_records#batch_create'
  get 'payroll_records', to: 'payroll_records#index'
  
  # Other routes for individual payroll records
  resources :employees do
    resources :payroll_records, only: [:index, :show, :create, :update, :destroy]
  end
  
  get 'calculate', to: 'tax_calculator#calculate'
  get 'net_pay/show', to: 'net_pay#show'
  root 'net_pay#show'
end
