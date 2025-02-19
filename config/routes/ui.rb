# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :ui do
    get :components, to: 'components#index'
    get :typography, to: 'typography#index'
    get :buttons, to: 'buttons#index'
    get :icons, to: 'icons#index'
    get :inputs, to: 'inputs#index'
  end
end
