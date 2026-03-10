# frozen_string_literal: true

NeoComponents.authentication_filter = :authenticate_admin!

# Expose gem stylesheet path so postcss-import can resolve @import directives when Tailwind CLI runs.
ENV['NEO_COMPONENTS_STYLESHEETS'] ||= NeoComponents::Engine.gem_root.join('app/assets/stylesheets').to_s
