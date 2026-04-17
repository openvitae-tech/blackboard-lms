# frozen_string_literal: true

ContentStudio::Engine.routes.draw do
  root to: 'courses#index'
  get 'courses/new', to: 'courses/wizard#new', as: :new_course
  post 'courses', to: 'courses/wizard#create', as: :courses
end
