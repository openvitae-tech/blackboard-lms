# frozen_string_literal: true

Rails.application.routes.draw do
  resources :teams

  resources :invites, only: %i[new create] do
    member do
      put :resend
    end

    collection do
      get :new_admin
      post :create_admin
    end
  end

  resources :notifications, only: [:index]

  resources :course_assigns, param: :user_id, only: [:new, :create]

  resource :settings, only: %i[show edit update] do
    collection do
      get :change_password
      put :update_password
    end
  end

  resources :events, only: [:index]

  resources :courses do
    member do
      put :enroll
      put :unenroll
      get :proceed
      put :publish
      put :unpublish
    end

    collection do
      get :search
    end

    resources :course_modules, as: 'modules', except: [:index] do
      member do
        put :moveup
        put :movedown
      end

      resources :lessons, except: [:index] do
        member do
          post :complete
          put :moveup
          put :movedown
          put :replay
        end
      end
      resources :quizzes, except: [:index] do
        member do
          post :submit_answer
          put :moveup
          put :movedown
        end
      end
    end
  end

  resources :learning_partners
  resources :dashboards, only: %i[index]

  resources :logins, only: %i[new create] do
    collection do
      post :otp
    end
  end

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    sessions: 'users/sessions'
  }

  resources :users

  get 'error_401' => 'pages#unauthorized'
  get 'dashboard' => 'dashboards#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'courses#index'
end
