# frozen_string_literal: true

ContentStudio::Engine.routes.draw do
  root to: 'courses#index'
  get 'new', to: 'creations#new', as: :new_creation
  get 'classroom-kits/:id/generation_status', to: 'classroom_kits/wizard#generation_status', as: :kit_generation_status
  get 'classroom-kits/:id/structure', to: 'classroom_kits/structure#show',
                                      as: :kit_structure
  get 'classroom-kits/:id/components/:component_id/download', to: 'classroom_kits/structure#download',
                                                              as: :download_kit_component
  get 'classroom-kits/:id/download_all', to: 'classroom_kits/structure#download_all',
                                         as: :download_all_kit_components
  patch 'classroom-kits/:id/save', to: 'classroom_kits/structure#save', as: :save_classroom_kit
  delete 'classroom-kits/:id', to: 'classroom_kits/structure#discard', as: :discard_kit
  get  'classroom-kits/new',            to: 'classroom_kits/wizard#new',          as: :new_classroom_kit
  post 'classroom-kits',                to: 'classroom_kits/wizard#create',       as: :classroom_kits
  get  'classroom-kits/:id/configure',  to: 'classroom_kits/wizard#configure',    as: :configure_classroom_kit
  patch 'classroom-kits/:id/configure', to: 'classroom_kits/wizard#update_config'
  get  'classroom-kits/:id/generating',        to: 'classroom_kits/wizard#generating',
                                               as: :generating_classroom_kit
  post 'classroom-kits/start_generation',      to: 'classroom_kits/wizard#start_generation', as: :start_kit_generation
  get   'microlessons/new',            to: 'microlessons/wizard#new',          as: :new_microlesson
  post  'microlessons',                to: 'microlessons/wizard#create',       as: :microlessons
  get   'microlessons/:id/configure',  to: 'microlessons/wizard#configure',    as: :configure_microlesson
  patch 'microlessons/:id/configure',  to: 'microlessons/wizard#update_config'
  get   'microlessons/:id/generating',   to: 'microlessons/wizard#generating',       as: :generating_microlesson
  get   'microlessons/:id/status',       to: 'microlessons/wizard#status',           as: :microlesson_status
  post  'microlessons/start_generation', to: 'microlessons/wizard#start_generation', as: :start_microlesson_generation
  get 'courses/new', to: 'courses/wizard#new', as: :new_course
  post 'courses', to: 'courses/wizard#create', as: :wizard_courses
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
  patch 'courses/:course_id/lessons/:id/reorder', to: 'courses/lessons#reorder', as: :reorder_course_lesson
  delete 'courses/:course_id/modules/:id', to: 'courses/modules#destroy', as: :destroy_course_module
  delete 'courses/:course_id/lessons', to: 'courses/modules#bulk_destroy_lessons',
                                       as: :bulk_destroy_course_lessons
  delete 'courses/:course_id/lessons/:id', to: 'courses/lessons#destroy', as: :destroy_course_lesson
  post 'courses/:course_id/lessons/:id/regenerate', to: 'courses/lessons#regenerate', as: :regenerate_lesson
end
