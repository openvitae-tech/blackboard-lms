# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :ui do
    get :components, to: 'components#index'
    get :typography, to: 'typography#index'
    get :buttons, to: 'buttons#index'
    get :icons, to: 'icons#index'
    get :inputs, to: 'inputs#index'
    get 'inputs/text_field', to: 'inputs#text_field'
    get 'inputs/radio_button', to: 'inputs#radio_button'
    get 'inputs/checkbox', to: 'inputs#checkbox'
    get 'inputs/file_selector', to: 'inputs#file_selector'
    get 'inputs/mobile_inputs', to: 'inputs#mobile_inputs'
    get 'inputs/textarea', to: 'inputs#textarea'
    get 'inputs/dropdown', to: 'inputs#dropdown'
    get 'inputs/date_picker', to: 'inputs#date_picker'
    get :tables, to: 'tables#index'
    get :notification_bars, to: 'notification_bars#index'
    get :app_components, to: 'components#app'
    get :menu_component, to: 'menu_component#index'
    get :breadcrumbs, to: 'breadcrumbs#index'
    get :modal_component, to: 'modal#index'
    get :modal_preview, to: 'modal#preview'
    get :success_modal, to: 'modal#success_modal'
    get :chip, to: 'chips#index'
    get :progress, to: 'progress#index'
    get :profile_icon, to: 'profile_icon#index'
  end
end
