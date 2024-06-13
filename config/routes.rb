Rails.application.routes.draw do
  resources :notifications, only: [:index]

  resource :settings, only: [:index, :update, :edit] do
    collection do
      get :team
      put :update_password
      post :invite_admin
      post :invite_member
      get :resend_invitation
    end
  end

  resources :events, only: [:index]
  resources :quizzes

  resources :courses do
    member do
      put :enroll
      put :unenroll
      get :proceed
    end

    collection do
      get :search
    end

    resources :course_modules, as: "modules", except: [:index] do
      resources :lessons, except: [:index] do
        member do
          get :complete
        end
      end
      resources :quizzes, except: [:index]
    end
  end

  resources :learning_partners
  devise_for :users
  resources :users
  # for now dashboard path and root path are same.
  get "error_401" => "pages#unauthorized"
  get "dashboard" => "dashboards#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "dashboards#index"
end
