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

    def modal_box_component(title: nil, variant: nil, modal_footer: nil, html_options: {},
                            wrapper_html_options: {}, close_action: 'click->modals#closeModal', &)
      modal = ModalBoxComponent.new(title:, variant:)
      block_content = capture(&) if block_given?

      container_class = variant == :success ? 'modal-success' : 'modal-container'

      wrapper_class = ['modal-wrapper', wrapper_html_options[:class]].compact.join(' ')
      merged_wrapper_options = { data: { controller: 'modals', modals_target: 'modalBox' } }
                                  .deep_merge(wrapper_html_options.except(:class))
                                  .merge(class: wrapper_class)

      content_class = ['modal-content', html_options[:class]].compact.join(' ')
      merged_content_options = html_options.except(:class).merge(class: content_class)

      render partial: 'view_components/modal_component/modal_box_component',
             locals: { modal:, body: block_content, modal_footer:, container_class:,
                       wrapper_html_options: merged_wrapper_options,
                       html_options: merged_content_options,
                       close_action: }
    end
  end
end
