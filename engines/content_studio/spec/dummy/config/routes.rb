Rails.application.routes.draw do
  mount ContentStudio::Engine => '/content_studio'

  namespace :api do
    namespace :internal do
      get 'courses/stats', to: 'courses#stats'
      get 'courses/metadata', to: 'courses#metadata'
      get 'courses', to: 'courses#index'
      get 'users/me', to: 'users#me'
    end
  end
end
