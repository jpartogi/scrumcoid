Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  resources :courses, only: [:index, :show]
  resource :about, only: [:show], controller: "about"
  resource :contact, only: [:new, :create], controller: "contact_messages"
  resources :class_schedules, only: [:index, :show] do
    resource :enrollment, only: [:destroy]
    resources :registrations, only: [:new, :create], controller: "class_schedules/registrations"
  end
  resources :blog_posts, path: "blog", only: [:index, :show]
  resource :dashboard, only: [:show], controller: "dashboard"

  namespace :admin do
    root "dashboard#show"
    resources :courses do
      member do
        patch :publish
        patch :unpublish
      end
    end
    resources :class_schedules do
      member do
        patch :publish
        patch :unpublish
      end
    end
    resources :venues
    resources :blog_posts do
      member do
        patch :publish
        patch :unpublish
      end
    end
    resource :about_page, only: [:edit, :update]
    resources :contact_messages, only: [:index, :show, :destroy] do
      member do
        patch :mark_read
        patch :archive
      end
    end
    resources :enrollments, only: [:show, :edit, :update, :destroy]
    resources :registrations, only: [:index, :show, :destroy]
    resources :admin_contacts
    resources :customers
  end

  get "sitemap.xml" => "sitemaps#show", defaults: { format: "xml" }
  get "up" => "rails/health#show", as: :rails_health_check
end
