# frozen_string_literal: true

module ViewComponent
  module Card
    module CourseCardComponent
      def course_card_component(
        title:,
        banner_url:,
        duration:,
        modules_count:,
        enroll_count:,
        categories: [],
        rating: nil,
        progress: nil,
        badge: nil,
        description: nil,
        highlights: []
      )
        render partial: 'view_components/cards/course_card_component', locals: {
          title:,
          banner_url:,
          duration:,
          modules_count:,
          enroll_count:,
          categories:,
          rating:,
          progress:,
          badge:,
          description:,
          highlights:
        }
      end
    end
  end
end
