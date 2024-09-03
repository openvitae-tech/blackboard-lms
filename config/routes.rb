Rails.application.routes.draw do
  resources :invites, only: [:new, :create] do
    member do
      get :resend
    end

    collection do
      get :new_admin
      post :create_admin
    end
  end

  resources :notifications, only: [:index]

  resources :course_assigns, param: :user_id, only: [] do
    member do
      get :list
      post :assign
    end
  end


  resource :settings, only: [:index, :update, :edit] do
    collection do
      get :team
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
      get :list
    end

    resources :course_modules, as: "modules", except: [:index] do
      member do
        put :moveup
        put :movedown
      end

      resources :lessons, except: [:index] do
        member do
          post :complete
          put :moveup
          put :movedown
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

  resources :logins, only: [:new, :create] do
    collection do
      post :otp
    end
  end

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
