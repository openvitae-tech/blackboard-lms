# frozen_string_literal: true

module ViewComponent
  module ModalBoxComponent
    class ModalBoxComponent
      attr_accessor :title

      def initialize(title:)
        self.title = title
      end
    end

    def modal_box_component(title:, &)
      modal = ModalBoxComponent.new(title:)
      block_content = capture(&) if block_given?

      render partial: 'view_components/modal_component/modal_box_component',
             locals: { modal:, body: block_content }
    end
  end
end
