Rails.application.routes.draw do
  resources :quizzes

  resources :courses do
    resources :course_modules, as: "modules", except: [:index] do
      resources :lessons, except: [:index]
      resources :quizzes, except: [:index]
    end
  end

  resources :learning_partners
  devise_for :users
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "pages#index"
end
