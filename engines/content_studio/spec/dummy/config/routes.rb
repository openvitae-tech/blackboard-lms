Rails.application.routes.draw do
  mount ContentStudio::Engine => '/content_studio'

  namespace :api do
    namespace :internal do
      get 'courses/stats', to: 'courses#stats'
      get 'courses/metadata', to: 'courses#metadata'
      get 'courses/avatars', to: 'courses#avatars'
      get 'courses/templates', to: 'courses#templates'
      get 'courses', to: 'courses#index'
      get 'users/me', to: 'users#me'
    end
  end
end
