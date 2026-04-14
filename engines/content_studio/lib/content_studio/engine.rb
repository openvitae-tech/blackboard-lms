# frozen_string_literal: true

module ContentStudio
  class Engine < ::Rails::Engine
    isolate_namespace ContentStudio

    initializer 'content_studio.set_parent_controller' do
      ContentStudio.parent_controller = '::ApplicationController'
    end

    initializer 'content_studio.assets' do |app|
      images_path = root.join('app/assets/images')
      app.config.assets.paths << images_path
      # Declare every image as precompilable so views can reference them via image_tag.
      images_glob = images_path.join('*')
      app.config.assets.precompile += Dir[images_glob].map { |f| File.basename(f) }
    end

    initializer 'content_studio.include_helpers' do |app|
      app.config.to_prepare do
        ActionView::Base.include ContentStudio::ApplicationHelper
      end
    end
  end
end
