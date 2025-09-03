# frozen_string_literal: true

module ViewComponent
  module CourseSelectComponent
    def course_select_component(search_context:, submit_path:, courses: [], tags: [], cancel_link: nil,
                                show_duration: false)
      render partial: 'view_components/app/course_select/course_select_component',
             locals: { search_context:, courses:, tags:, cancel_link:, show_duration:, submit_path: }
    end

    def _course_select_search_component(search_context:, tags:)
      render partial: 'view_components/app/course_select/search_component', locals: { search_context:, tags: }
    end

    def _course_select_sidebar_component(form:, tags:)
      render partial: 'view_components/app/course_select/sidebar_component', locals: { form:, tags: }
    end

    def _course_select_list_component(search_context:, courses:)
      render partial: 'view_components/app/course_select/list_component',
             locals: { search_context:, courses: }
    end

    def _course_select_list_item_component(course:)
      render partial: 'view_components/app/course_select/list_item_component', locals: { course: }
    end

    def _course_select_load_more(search_context:, courses:)
      render partial: 'view_components/app/course_select/load_more', locals: { search_context:, courses: }
    end
  end
end
