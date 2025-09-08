# frozen_string_literal: true

module ViewComponent
  module ModalComponent
    # modal box component
    # @param title - modal title
    def modal_component(title:, &)
      block_content = capture(&) if block_given?
      render partial: 'view_components/modals/modal_component', locals: { title:, body: block_content }
    end
  end
end
