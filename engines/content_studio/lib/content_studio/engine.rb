# frozen_string_literal: true

module ContentStudio
  class Engine < ::Rails::Engine
    isolate_namespace ContentStudio

    initializer 'content_studio.set_parent_controller' do
      ContentStudio.parent_controller = '::ApplicationController'
    end

    initializer 'content_studio.include_helpers' do |app|
      app.config.to_prepare do
        ActionView::Base.include ContentStudio::ApplicationHelper
      end
    end
  end
end
