# frozen_string_literal: true

module ViewComponent
  module Card
    module CourseCardComponent
      def course_card_component(course:, enrollment: nil)
        render partial: 'view_components/cards/course_card_component', locals: { course:, enrollment: }
      end
    end
  end
end
