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
        type_tag: nil,
        publish_status: nil
      )
        if checkbox && !checkbox.is_a?(Hash)
          raise ArgumentError,
                'checkbox must be false or a Hash of check_box_tag options'
        end

        unless publish_status.nil? || %w[published unpublished].include?(publish_status)
          raise ArgumentError,
                "publish_status must be 'published', 'unpublished', or nil"
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
                 type_tag:,
                 publish_status:
               }
      end
    end
  end
end
