# frozen_string_literal: true

ContentStudio::Engine.routes.draw do
  root to: 'courses#index'
  get 'new', to: 'creations#new', as: :new_creation
  get  'classroom-kits/new',            to: 'classroom_kits/wizard#new',          as: :new_classroom_kit
  post 'classroom-kits',                to: 'classroom_kits/wizard#create',       as: :classroom_kits
  get  'classroom-kits/:id/configure',  to: 'classroom_kits/wizard#configure',    as: :configure_classroom_kit
  patch 'classroom-kits/:id/configure', to: 'classroom_kits/wizard#update_config'
  get  'classroom-kits/:id/generating',        to: 'classroom_kits/wizard#generating',        as: :generating_classroom_kit
  get  'classroom-kits/error',                 to: 'classroom_kits/wizard#error',             as: :classroom_kit_error
  post 'classroom-kits/start_generation',      to: 'classroom_kits/wizard#start_generation',  as: :start_kit_generation
  get  'classroom-kits/:id/generation_status', to: 'classroom_kits/wizard#generation_status', as: :kit_generation_status
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
  post 'courses/:course_id/lessons/:id/verify', to: 'courses/lessons#verify', as: :verify_lesson
  get 'courses/:course_id/lessons/:id/scene_status', to: 'courses/lessons#scene_status', as: :lesson_scene_status
  get 'courses/:course_id/lessons/:id/download', to: 'courses/lessons#download', as: :download_course_lesson
  post 'courses/:course_id/lessons/:lesson_id/scenes/:scene_id/regenerate',
       to: 'courses/scenes#regenerate',
       as: :regenerate_scene
  delete 'courses/:course_id/lessons/:id', to: 'courses/lessons#destroy', as: :destroy_course_lesson
  post 'courses/:course_id/lessons/:id/regenerate', to: 'courses/lessons#regenerate', as: :regenerate_lesson
end
