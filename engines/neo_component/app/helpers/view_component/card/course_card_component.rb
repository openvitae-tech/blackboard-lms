# frozen_string_literal: true

module ViewComponent
  module Card
    module CourseCardComponent
      def course_card_component(
        title:,
        banner_url:,
        modules_count:,
        duration: nil,
        enroll_count: nil,
        modules_label: 'Lesson',
        categories: [],
        rating: nil,
        progress: nil,
        badge: nil,
        description: nil,
        highlights: [],
        type_tag: nil,
        card_width: 312
      )
        badge = { bg_color: 'bg-secondary', text_color: 'text-primary-dark' }.merge(badge) if badge
        render partial: 'view_components/cards/course_card_component', locals: {
          title:,
          banner_url:,
          duration:,
          modules_count:,
          enroll_count:,
          modules_label:,
          categories:,
          rating:,
          progress:,
          badge:,
          description:,
          highlights:,
          type_tag:,
          card_width:
        }
      end
    end
  end
end
