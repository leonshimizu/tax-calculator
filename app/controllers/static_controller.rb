class StaticController < ApplicationController
  before_action :ensure_user_approved, except: [:index]

  def index
    render file: Rails.root.join('public', 'index.html'), layout: false
  end
end
