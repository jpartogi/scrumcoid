Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  resources :courses, only: [:index, :show]
  resource :about, only: [:show], controller: "about"
  resource :contact, only: [:new, :create], controller: "contact_messages"
  resources :class_schedules, only: [:index] do
    resource :enrollment, only: [:destroy]
    resources :registrations, only: [:new, :create], controller: "class_schedules/registrations"
  end
  resources :meetups, only: [:index, :show] do
    resources :registrations, only: [:new, :create], controller: "meetups/registrations"
  end
  get "class_schedules/:course_slug/:id", to: "class_schedules#show", as: :class_schedule
  resources :resources, only: [:index, :show] do
    resources :download_requests, only: [:new, :create], controller: "resources/download_requests"
  end
  get "resource-downloads/:token", to: "resource_downloads#show", as: :resource_download
  resources :blog_posts, path: "blog", only: [:index, :show]
  resource :dashboard, only: [:show], controller: "dashboard"

  namespace :admin do
    root "dashboard#show"
    resource :traffic, only: [:show], controller: "traffic"
    resources :courses do
      member do
        patch :publish
        patch :unpublish
      end
      resource :invitation_email, only: [:show, :edit, :update], controller: "courses/invitation_emails"
    end
    resources :class_schedules do
      member do
        patch :publish
        patch :unpublish
        get :export_enrollments
      end
      resources :enrollments, only: [:new, :create], controller: "class_schedules/enrollments"
      resource :invitations, only: [:new, :create], controller: "class_schedules/invitations" do
        post :test
      end
    end
    resources :meetups do
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
    resources :resources do
      member do
        patch :publish
        patch :unpublish
      end
      resources :download_requests, only: [:index], controller: "resources/download_requests"
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
    resources :students, only: [:index]
    resources :leads, only: [:index], controller: "crm_leads"
  end

  get "invitations/track/:token" => "invitation_tracking#show", as: :track_invitation
  get "sitemap.xml" => "sitemaps#show", defaults: { format: "xml" }
  get "up" => "rails/health#show", as: :rails_health_check
end
