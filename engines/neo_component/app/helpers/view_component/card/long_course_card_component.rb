# frozen_string_literal: true

module ViewComponent
  module Card
    module LongCourseCardComponent
      def long_course_card_component(
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
        highlights: [],
        checkbox: false,
        type_tag: nil
      )
        if checkbox && !checkbox.is_a?(Hash)
          raise ArgumentError,
                'checkbox must be false or a Hash of check_box_tag options'
        end

        badge = { bg_color: 'bg-secondary', text_color: 'text-primary-dark' }.merge(badge) if badge
        render partial: 'view_components/cards/long_course_card_component',
               locals: {
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
                 highlights:,
                 checkbox:,
                 type_tag:
               }
      end
    end
  end
end
