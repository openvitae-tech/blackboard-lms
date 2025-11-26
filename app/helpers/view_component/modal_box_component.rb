# frozen_string_literal: true

module ViewComponent
  module ModalBoxComponent
    class ModalBoxComponent
      attr_accessor :title, :variant

      def initialize(title: nil, variant: nil)
        self.title = title
        self.variant = variant
      end
    end

    def modal_box_component(title: nil, variant: nil, &)
      modal = ModalBoxComponent.new(title:, variant:)
      block_content = capture(&) if block_given?

      container_class =
        if variant == :success
          'modal-success'
        else
          'modal-container'
        end

      render partial: 'view_components/modal_component/modal_box_component',
             locals: { modal:, body: block_content, container_class: }
    end
  end
end
