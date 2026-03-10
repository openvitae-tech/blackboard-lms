# frozen_string_literal: true

# Expose neo_components gem stylesheet path to postcss-import before Tailwind builds.
# postcss.config.js reads ENV['NEO_COMPONENTS_STYLESHEETS'] to resolve @import paths.
namespace :tailwindcss do
  task set_neo_components_path: :environment do
    ENV['NEO_COMPONENTS_STYLESHEETS'] = NeoComponents::Engine.gem_root.join('app/assets/stylesheets').to_s
  end
end

Rake::Task['tailwindcss:build'].enhance(['tailwindcss:set_neo_components_path'])
Rake::Task['tailwindcss:watch'].enhance(['tailwindcss:set_neo_components_path'])
