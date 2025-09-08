# frozen_string_literal: true

module ViewComponent
  module PaginatorComponent
    def paginator_component(collection:, path:)
      render partial: 'view_components/paginator/paginator_component', locals: { collection:, path: }
    end
  end
end
