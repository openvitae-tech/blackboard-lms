# frozen_string_literal: true

module NeoComponents
  module Ui
    class ModalController < BaseController
      def index
      end

      def preview
        render partial: "neo_components/ui/modal/sample_modal"
      end

      def success_modal
        render partial: "neo_components/ui/modal/success_modal"
      end

      def footer_modal
        render partial: "neo_components/ui/modal/footer_modal"
      end
    end
  end
end
