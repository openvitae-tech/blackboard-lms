# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Pull compiled assets (tailwind.css, application.css, inter-font.css, images) from the main app.
Rails.application.config.assets.paths << Rails.root.join('../../../../app/assets/builds')
Rails.application.config.assets.paths << Rails.root.join('../../../../app/assets/stylesheets')
Rails.application.config.assets.paths << Rails.root.join('../../../../app/assets/images')

# stimulus-rails ships stimulus-loading.js — add its asset path explicitly.
stimulus_gem = Gem::Specification.find_by_name('stimulus-rails')
Rails.application.config.assets.paths << File.join(stimulus_gem.gem_dir, 'app/assets/javascripts') if stimulus_gem

# Precompile assets from external paths not covered by manifest directories.
Rails.application.config.assets.precompile += %w[tailwind.css application.css inter-font.css]
