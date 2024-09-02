Rails.application.routes.draw do
  # User authentication routes
  post "/users" => "users#create"
  post "/sessions" => "sessions#create"
  post "/sessions/refresh" => "sessions#refresh" # Add this line for token refresh

  # Route to get the current user
  get 'current_user', to: 'users#show_current_user'

  # Admin namespace for managing users
  namespace :admin do
    resources :users, only: [:index, :update]
  end

  # Routes for companies and nested resources
  resources :companies do
    # Nested routes for departments within companies
    resources :departments do
      # You may add nested resources here if needed, such as employees under a specific department
    end

    resources :employees do
      resources :payroll_records, only: [:index, :show, :create, :update, :destroy]

      # Define collection route for employee file upload
      collection do
        post 'upload', to: 'employees#upload'
      end
    end

    # Routes for managing custom columns
    resources :custom_columns, only: [:index, :create, :destroy]

    # Route to fetch all payroll records for a company
    get 'payroll_records', to: 'payroll_records#index'

    # Route for batch payroll record upload within a company context
    resources :payroll_records, only: [] do
      collection do
        post 'upload', to: 'payroll_records#upload'
      end
    end

    # Route for uploading payroll master file
    post 'payroll_master_file/upload', to: 'files#upload_files'

    # Routes for YTD totals
    member do
      get 'department_ytd_totals', to: 'companies#department_ytd_totals'
      get 'company_ytd_totals', to: 'companies#company_ytd_totals'
    end
  end

  # Route for fetching payroll records across all companies by date
  get 'payroll_records', to: 'payroll_records#index'

  # Route to fetch YTD totals for an employee
  resources :employees do
    member do
      get 'ytd_totals', to: 'employees#ytd_totals'
    end
  end

  # New route for file upload at the root level
  post 'api/upload_files', to: 'files#upload_files'

  # Catch-all route for serving index.html for unknown paths (SPA support)
  get '*path', to: 'static#index', constraints: ->(req) { req.format.html? }

  get 'calculate', to: 'tax_calculator#calculate'
  get 'net_pay/show', to: 'net_pay#show'
  root 'net_pay#show'
end
