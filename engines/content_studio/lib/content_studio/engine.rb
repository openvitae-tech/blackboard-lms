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
      app.config.assets.paths << root.join('app/javascript')
      images_glob = images_path.join('*')
      app.config.assets.precompile += Dir[images_glob].map { |f| File.basename(f) }
      controllers_glob = root.join('app/javascript/content_studio/controllers/*.js')
      app.config.assets.precompile += Dir[controllers_glob].map do |f|
        "content_studio/controllers/#{File.basename(f)}"
      end
    end

    initializer 'content_studio.importmap', before: 'importmap' do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join('config/importmap.rb')
        app.config.importmap.cache_sweepers << root.join('app/javascript')
      end
    end

    initializer 'content_studio.include_helpers' do |app|
      app.config.to_prepare do
        ActionView::Base.include ContentStudio::ApplicationHelper
      end
    end
  end
end
