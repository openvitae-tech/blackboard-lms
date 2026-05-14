Rails.application.routes.draw do
  mount ContentStudio::Engine => '/content_studio'

  namespace :api do
    namespace :internal do
      get 'courses/stats', to: 'courses#stats'
      get 'courses/metadata', to: 'courses#metadata'
      get 'courses/avatars', to: 'courses#avatars'
      get 'courses/templates', to: 'courses#templates'
      get 'courses', to: 'courses#index'
      get 'courses/:id/generation_status', to: 'courses#generation_status'
      get 'courses/:id/structure', to: 'courses#structure'
      patch 'courses/:id/save', to: 'courses#save'
      delete 'courses/:id', to: 'courses#discard'
      get 'courses/:course_id/lessons/:id', to: 'courses/lessons#show'
      get 'users/me', to: 'users#me'
    end
  end
end
