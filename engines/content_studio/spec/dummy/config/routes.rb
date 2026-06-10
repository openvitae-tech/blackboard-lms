# frozen_string_literal: true

Rails.application.routes.draw do
  root to: proc { [200, {}, ['']] }

  get 'alert_modal', to: proc { [200, {}, ['']] }, as: :alert_modal

  mount ContentStudio::Engine => '/content_studio'

  namespace :api do
    namespace :internal do
      get 'courses/stats', to: 'courses#stats'
      get 'courses/metadata', to: 'courses#metadata'
      get 'courses/avatars', to: 'courses#avatars'
      get 'courses/templates', to: 'courses#templates'
      get 'courses', to: 'courses#index'
      get 'courses/:id/generation_status', to: 'courses#generation_status'
      get 'courses/:id/structure', to: 'courses#structure'
      patch 'courses/:id/save', to: 'courses#save'
      patch 'courses/:course_id/lessons/:lesson_id/reorder', to: 'courses#reorder_lesson'
      delete 'courses/:id', to: 'courses#discard'
      post 'courses/:course_id/lessons/:lesson_id/scenes/:scene_id/regenerate', to: 'courses#regenerate_scene'
      post 'courses/:course_id/lessons/:lesson_id/verify', to: 'courses#verify_lesson'
      delete 'courses/:course_id/modules/:module_id', to: 'courses#delete_module'
      delete 'courses/:course_id/lessons', to: 'courses#bulk_destroy_lessons'
      delete 'courses/:course_id/lessons/:lesson_id', to: 'courses#delete_lesson'
      post 'courses/:course_id/lessons/:lesson_id/regenerate', to: 'courses#regenerate_lesson'
      get 'courses/:course_id/lessons/:id', to: 'courses/lessons#show'
      get 'users/me', to: 'users#me'
    end
  end
end
