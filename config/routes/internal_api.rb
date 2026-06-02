# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :internal do
      get 'courses/stats', to: 'courses#stats'
      get 'courses/metadata', to: 'courses#metadata'
      get 'courses/avatars', to: 'courses#avatars'
      get 'courses/templates', to: 'courses#templates'
      get 'courses', to: 'courses#index'
      post 'courses', to: 'courses#create'
      post 'courses/:course_id/lessons/:lesson_id/scenes/:scene_id/regenerate', to: 'courses#regenerate_scene'
      post 'courses/:course_id/lessons/:lesson_id/verify', to: 'courses#verify_lesson'
      get 'courses/:id/generation_status', to: 'courses#generation_status'
      get 'courses/:id/structure', to: 'courses#structure'
      patch 'courses/:id/save', to: 'courses#save'
      delete 'courses/:id', to: 'courses#discard'
      delete 'courses/:course_id/lessons/:lesson_id', to: 'courses#delete_lesson'
      post 'courses/:course_id/lessons/:lesson_id/regenerate', to: 'courses#regenerate_lesson'
      get 'courses/:course_id/lessons/:id', to: 'courses/lessons#show'
    end
  end
end
