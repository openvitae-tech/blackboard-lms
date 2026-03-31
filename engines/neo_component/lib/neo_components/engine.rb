# frozen_string_literal: true

module NeoComponents
  class Engine < ::Rails::Engine
    isolate_namespace NeoComponents

    def self.gem_root
      Pathname.new(File.expand_path('../..', __dir__))
    end

    # Register Sprockets asset paths (icons, stylesheets, and javascript)
    initializer 'neo_components.assets' do |app|
      app.config.assets.paths << Engine.gem_root.join('app/assets/stylesheets')
      app.config.assets.paths << Engine.gem_root.join('app/assets/icons')
      app.config.assets.paths << Engine.gem_root.join('app/javascript')
      app.config.assets.precompile += %w[icons.css]
      # Declare all Stimulus controllers as precompilable so importmap can resolve their URLs
      controllers_glob = Engine.gem_root.join('app/javascript/neo_components/controllers/*.js')
      app.config.assets.precompile += Dir[controllers_glob].map do |f|
        "neo_components/controllers/#{File.basename(f)}"
      end
    end

    # Register gem view path so partials under app/views/ are found.
    # Uses to_prepare so the path is re-registered on every reload in development.
    initializer 'neo_components.view_paths' do |app|
      app.config.to_prepare do
        ActionController::Base.append_view_path NeoComponents::Engine.gem_root.join('app/views')
      end
    end

    # Auto-include UiHelper into all ActionView contexts.
    # Uses to_prepare so fresh module objects are re-included after every reload in development.
    initializer 'neo_components.include_helpers' do |app|
      app.config.to_prepare do
        ActionView::Base.include UiHelper
      end
    end

    # Register gem's Stimulus controllers with importmap-rails
    initializer 'neo_components.importmap', before: 'importmap' do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << Engine.gem_root.join('config/importmap.rb')
        app.config.importmap.cache_sweepers << Engine.gem_root.join('app/javascript')
      end
    end
  end
end
