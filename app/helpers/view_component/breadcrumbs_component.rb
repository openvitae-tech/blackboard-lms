# frozen_string_literal: true

module ViewComponent
  module BreadcrumbsComponent
    class BreadcrumbsComponent
      attr_accessor :links

      def initialize(links: [])
        self.links = links
      end

      def all_links
        links || []
      end

      def last_link
        all_links.last
      end

      def intermediate_links
        all_links[0..-2] || []
      end
    end

    def breadcrumbs_component(links: [])
      breadcrumbs = BreadcrumbsComponent.new(links:)
      render partial: 'view_components/breadcrumbs_component/breadcrumbs', locals: { breadcrumbs: }
    end
  end
end
