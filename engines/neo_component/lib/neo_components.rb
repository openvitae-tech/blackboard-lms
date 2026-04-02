# frozen_string_literal: true

require 'neo_components/version'
require 'neo_components/engine'

module NeoComponents
  # Optional symbol/proc for authentication used by the UI showcase controllers.
  # Example in a Rails initializer:
  #   NeoComponents.authentication_filter = :authenticate_admin!
  mattr_accessor :authentication_filter, default: nil
end
