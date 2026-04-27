# frozen_string_literal: true

ContentStudio::Engine.routes.draw do
  root to: 'courses#index'
  get 'courses/new', to: 'courses/wizard#new', as: :new_course
  post 'courses', to: 'courses/wizard#create', as: :courses
  get 'courses/:id/configure_video', to: 'courses/wizard#configure_video', as: :configure_video
  patch 'courses/:id/configure_video', to: 'courses/wizard#update_video_config'
  get 'courses/:id/generating', to: 'courses/wizard#generating', as: :generating_course
  post 'courses/start_generation', to: 'courses/wizard#start_generation', as: :start_generation
  get 'courses/:id/generation_status', to: 'courses/wizard#generation_status', as: :generation_status
  get 'courses/:id/structure', to: 'courses/structure#show', as: :course_structure
  patch 'courses/:id/save', to: 'courses/structure#save', as: :save_course
  delete 'courses/:id', to: 'courses/structure#discard', as: :discard_course
  get 'courses/:course_id/lessons/:id', to: 'courses/lessons#show', as: :course_lesson
end
