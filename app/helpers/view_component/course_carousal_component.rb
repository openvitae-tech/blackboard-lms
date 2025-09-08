# frozen_string_literal: true

module ViewComponent
  module CourseCarousalComponent
    def course_carousal_component(courses:, title:, count:, load_path:)
      render partial: 'view_components/course_carousal/course_carousal_component',
             locals: { courses:, title:, count:, load_path: }
    end

    def course_carousal_body_component(courses:)
      render partial: 'view_components/course_carousal/course_carousal_body_component', locals: { courses: }
    end
  end
end
