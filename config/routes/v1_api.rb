# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
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
