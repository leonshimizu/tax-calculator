Rails.application.routes.draw do
  # Define a separate route for batch processing within the context of a company
  post 'companies/:company_id/employees/batch/payroll_records', to: 'payroll_records#batch_create'

  # Route for fetching payroll records across all companies by date
  get 'payroll_records', to: 'payroll_records#index'

  # Define routes for companies
  resources :companies do
    resources :employees do
      resources :payroll_records, only: [:index, :show, :create, :update, :destroy]

      # Define collection route for file upload
      collection do
        post 'upload', to: 'employees#upload'
      end
    end

    # Routes for managing custom columns
    resources :custom_columns, only: [:index, :create, :destroy]

    # Route to fetch all payroll records for a company
    get 'payroll_records', to: 'payroll_records#index'

    # Routes for YTD totals
    member do
      get 'department_ytd_totals', to: 'companies#department_ytd_totals'
      get 'company_ytd_totals', to: 'companies#company_ytd_totals'
    end
  end

  # Route to fetch YTD totals for an employee
  resources :employees do
    member do
      get 'ytd_totals', to: 'employees#ytd_totals'
    end
  end

  # This line ensures that any unknown route serves the index.html
  get '*path', to: 'static#index', constraints: ->(req) { req.format.html? }

  get 'calculate', to: 'tax_calculator#calculate'
  get 'net_pay/show', to: 'net_pay#show'
  root 'net_pay#show'
end

