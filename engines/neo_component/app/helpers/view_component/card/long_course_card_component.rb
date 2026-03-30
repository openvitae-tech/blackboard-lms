# frozen_string_literal: true

module ViewComponent
  module Card
    module LongCourseCardComponent
      def long_course_card_component(course:, enrollment: nil, program: nil)
        render partial: 'view_components/cards/long_course_card_component',
               locals: { course:, enrollment:, program: }
      end
    end
  end
end
