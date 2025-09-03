# frozen_string_literal: true

module ViewComponent
  module CourseCardComponent
    def course_card_component(course:, enrollment: nil)
      render partial: 'view_components/course_carousal/course_card_component', locals: { course:, enrollment: }
    end
  end
end
