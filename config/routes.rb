# frozen_string_literal: true

Rails.application.routes.draw do
  resources :user_searches, only: %i[index create]
  resources :reports, only: %i[new create show]

  resources :searches, only: [:index] do
    collection do
      match '/', to: 'searches#index', via: %i[get post], as: ''
      get :list
      get :load_more
    end
  end

  namespace :onboarding do
    resource :welcome, only: %i[new update] do
      collection do
        get :set_name_and_email
        get :set_dob_and_gender
        get :set_language
        get :set_password
        put :update_password
        get :all_set
      end
    end
  end

  resources :teams, except: %i[index destroy] do
    member do
      get :all_users
      get :sub_teams
    end
  end

  resources :direct_uploads, only: :create

  resources :invites, only: %i[new create] do
    member do
      put :resend
    end

    collection do
      get :new_admin
      post :create_admin
      get :download
    end
  end

  resources :notifications, only: [:index] do
    collection do
      get :count
      get :clear
      get :mark_as_read
    end
  end

  resources :course_assigns, param: :user_id, only: %i[new create]

  resource :user_settings, only: %i[show edit update] do
    collection do
      get :change_password
      put :update_password
    end
  end

  resources :events, only: :index
  resources :tags, except: :show
  resource :profile, only: :show, controller: 'my_profiles' do
    collection do
      get :share_certificate
      post :generate_certificate
    end
  end

  resources :certificates, only: :show

  resource :alert_modal, only: :show, controller: 'commons/alert_modal'

  resources :courses do
    member do
      put :enroll
      put :unenroll
      get :proceed
      put :publish
      put :unpublish
    end

    resource :scorm, only: %i[new create] do
      collection do
        get :download
      end
    end

    resources :course_modules, as: 'modules', except: :index do
      member do
        put :moveup
        put :movedown
        get :summary
        delete :redo_quiz
      end

      resources :lessons, except: :index do
        member do
          post :complete
          put :moveup
          put :movedown
        end
        resource :rating, only: %i[new create], module: :lesson
      end

      resources :quizzes, except: :index do
        member do
          post :submit_answer
          put :moveup
          put :movedown
        end
        collection do
          get :generate
        end
      end
    end
  end

  resources :local_contents do
    member do
      put :retry
    end
  end

  resources :learning_partners do
    member do
      put :activate
      put :deactivate
    end

    resource :payment_plan, only: %i[new create edit update]
    resources :certificate_templates, only: %i[new index create update destroy] do
      member do
        get :confirm_destroy
      end
    end
  end

  resources :programs, only: %i[new index show create edit update destroy] do
    member do
      delete :bulk_destroy_courses
      get :confirm_bulk_destroy_courses
      get :confirm_destroy
      get :add_courses
      post :create_courses
    end

    collection do
      get :list
      post :choose
    end
  end

  resources :dashboards, only: :index
  resources :settings, only: :index

  resource :login, only: %i[new create] do
    collection do
      post :otp
    end
  end

  namespace :embeds do
    resources :videos, only: :show
  end

  resource :impersonation, only: %i[create destroy]

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    sessions: 'users/sessions'
  }

  resources :users, only: %i[show destroy], as: 'members', path: 'member' do
    member do
      get :deactivate
      post :confirm_deactivate
      get :activate
      post :confirm_activate
      get :change_team
      patch :confirm_change_team
      get :change_role
      patch :confirm_change_role
      get :select_roles
    end
  end

  resources :supports, only: :index

  get 'error_401' => 'pages#unauthorized'
  get 'dashboard' => 'dashboards#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  devise_scope :user do
    authenticated do
      root 'home#index', as: :authenticated_root
    end

    unauthenticated do
      root 'logins#new', as: :unauthenticated_root
    end
  end

  draw :ui
  draw :sidekiq_web
  draw :v1_api
  draw :catch_all
end
