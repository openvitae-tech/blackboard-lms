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
        validate_checkbox_arg!(checkbox)
        validate_type_tag_arg!(type_tag)
        validate_publish_status_arg!(publish_status)
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

      private

      def validate_checkbox_arg!(checkbox)
        return unless checkbox && !checkbox.is_a?(Hash)

        raise ArgumentError, 'checkbox must be false or a Hash of check_box_tag options'
      end

      def validate_type_tag_arg!(type_tag)
        return unless type_tag && (!type_tag.is_a?(Hash) || type_tag[:label].blank? || type_tag[:bg_color].blank?)

        raise ArgumentError, 'type_tag must be nil or a Hash with :label and :bg_color'
      end

      def validate_publish_status_arg!(publish_status)
        return if publish_status.nil? || %w[published unpublished].include?(publish_status)

        raise ArgumentError, "publish_status must be 'published', 'unpublished', or nil"
      end
    end
  end
end
