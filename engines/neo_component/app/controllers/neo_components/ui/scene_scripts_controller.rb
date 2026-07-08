# frozen_string_literal: true

module NeoComponents
  module Ui
    class SceneScriptsController < BaseController
      def index; end

      def noop
        head :ok
      end
    end
  end
end
