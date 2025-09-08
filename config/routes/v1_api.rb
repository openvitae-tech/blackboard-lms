# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :otps, only: [] do
        collection do
          get :generate
          get :verify
        end
      end
    end
  end
end
