# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :ui do
    get :components, to: 'components#index'
    get :typography, to: 'typography#index'
    get :buttons, to: 'buttons#index'
    get :icons, to: 'icons#index'
    get :inputs, to: 'inputs#index'
    get :tables, to: 'tables#index'
    get :notification_bars, to: 'notification_bars#index'
  end
end
