# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :otps, only: [] do
        collection do
          post :generate
          post :verify
        end
      end
      resource :one_timer_task, only: [] do
        collection do
          get :run_tasks
        end
      end
    end
  end
end
