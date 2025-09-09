# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :otps, only: [] do
        collection do
          post :generate
          post :verify
          post :generate_or_verify # special case
        end
      end
    end
  end
end
