# config/routes.rb
Rails.application.routes.draw do
  # User authentication routes
  post "/users", to: "users#create"
  post "/sessions", to: "sessions#create"
  post "/sessions/refresh", to: "sessions#refresh"

  # Route to get the current user
  get 'current_user', to: 'users#show_current_user'

  # Admin namespace for managing users
  namespace :admin do
    resources :users, only: [:index, :update]
  end

  # Routes for companies and nested resources
  resources :companies do
    member do
      get 'company_ytd_totals'  # Dynamically calculate YTD totals for a company
      post 'update_ytd_totals'  # Trigger YTD totals update for a company
    end

    resources :departments, only: [:index, :show, :create, :update, :destroy] do
      member do
        get 'ytd_totals'  # Dynamically calculate YTD totals for a department
      end
    end

    resources :employees do
      collection do
        post 'upload', to: 'employees#upload'  # Bulk upload employees
        get 'ytd_totals', to: 'employees#ytd_totals'  # Calculate YTD totals for all employees in a company
      end

      member do
        # get 'ytd_totals'  # Dynamically calculate YTD totals for a specific employee (optional)
      end

      resources :payroll_records, only: [:index, :show, :create, :update, :destroy]
    end

    # Routes for managing custom columns
    resources :custom_columns, only: [:index, :create, :destroy]

    # Route to fetch all payroll records for a company
    get 'payroll_records', to: 'payroll_records#index'

    # Separate payroll records route for bulk upload
    resources :payroll_records, only: [] do
      collection do
        post 'upload'  # Upload payroll records in bulk
      end
    end

    # Route for uploading payroll master file
    post 'payroll_master_file/upload', to: 'files#upload_files'
  end

  # Route for file upload at the root level
  post 'upload_files', to: 'files#upload_files'

  # Additional routes
  get 'calculate', to: 'tax_calculator#calculate'
  get 'net_pay/show', to: 'net_pay#show'
  root 'net_pay#show'

  # Catch-all route for serving index.html for unknown paths (SPA support)
  get '*path', to: 'static#index', constraints: ->(req) { req.format.html? }
end
