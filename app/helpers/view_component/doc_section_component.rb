# frozen_string_literal: true

module ViewComponent
  module DocSectionComponent
    def doc_section_component(title: '', &)
      block_content = capture(&) if block_given?
      render partial: 'view_components/doc_section/doc_section_component', locals: { title:, block: block_content }
    end
  end
end
