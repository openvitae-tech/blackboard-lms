# frozen_string_literal: true

module Courses
  class FilterAdapter
    include Singleton

    def filter_courses(user, tags, term = '', type = '')
      type = type.blank? ? :all : type.to_sym
      search_context = SearchContext.new(context: :course_listing, tags:, term:, type:)

      if user.is_admin?
        search_context = search_context_with_type(search_context, :all)

        all = FilterService.new(user, search_context).filter
        {
          available_courses: all.records,
          available_courses_count: all.count
        }
      elsif search_context.search_all_courses?
        enrolled_search_context = search_context_with_type(search_context, SearchContext::ENROLLED)

        enrolled = FilterService.new(user, enrolled_search_context).filter
        unenrolled_search_context = search_context_with_type(search_context, SearchContext::UNENROLLED)
        unenrolled = FilterService.new(user, unenrolled_search_context).filter

        {
          enrolled_courses: enrolled.records,
          enrolled_courses_count: enrolled.count,
          available_courses: unenrolled.records,
          available_courses_count: unenrolled.count
        }
      elsif search_context.search_enrolled_courses?
        enrolled = FilterService.new(user, search_context).filter
        {
          enrolled_courses: enrolled.records,
          enrolled_courses_count: enrolled.count
        }
      elsif search_context.search_unenrolled_courses?
        unenrolled = FilterService.new(user, search_context).filter
        {
          available_courses: unenrolled.records,
          available_courses_count: unenrolled.count
        }
      end
    end

    private

    def search_context_with_type(ctx, type)
      SearchContext.new(
        context: ctx.context,
        term: ctx.term,
        tags: ctx.tags,
        type:
      )
    end
  end
end
