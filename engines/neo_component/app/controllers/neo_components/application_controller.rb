# frozen_string_literal: true

module NeoComponents
  class ApplicationController < ::ApplicationController
    before_action -> { @active_nav = 'settings' }

    helper NeoComponents::Engine.routes.url_helpers

    helper do
      def method_missing(method_name, *args, **kwargs, &block)
        if main_app.respond_to?(method_name)
          main_app.public_send(method_name, *args, **kwargs, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        main_app.respond_to?(method_name, include_private) || super
      end
    end
  end
end
