# frozen_string_literal: true

module ViewComponent
  module DocSectionComponent
    def doc_section_component(title: '', &demo)
      render partial: 'view_components/doc_section/doc_section_component', locals: { title:, demo: }
    end
  end
end
