# frozen_string_literal: true

module NeoComponents
  module Ui
    class IconsController < BaseController
      def index
        icons_path = NeoComponents::Engine.gem_root.join("app/assets/icons")
        @icons = Dir.entries(icons_path)
                    .select { |name| name.end_with?('.svg') }
                    .map { |name| name.sub(".svg", "") }
      end
    end
  end
end
