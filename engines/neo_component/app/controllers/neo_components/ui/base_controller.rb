# frozen_string_literal: true

module NeoComponents
  module Ui
    class BaseController < NeoComponents::ApplicationController
      before_action :authenticate_if_configured

      private

      # Delegates authentication to whatever filter the host app configures.
      # Configure in a Rails initializer:
      #   NeoComponents.authentication_filter = :authenticate_admin!
      def authenticate_if_configured
        send(NeoComponents.authentication_filter) if NeoComponents.authentication_filter
      end
    end
  end
end
