# frozen_string_literal: true

module Courses
  class FilterAdapter
    include Singleton

    def filter_courses(user, tags, term = '', type = '')
      type = type.blank? ? :all : type.to_sym
      search_context = SearchContext.new(context: :course_listing, tags:, term:, type:)

      if user.is_admin?
        search_context = search_context_with_type(search_context, :all)
        search_all(user, search_context)
      elsif search_context.search_all_courses?
        enrolled_search_context = search_context_with_type(search_context, SearchContext::ENROLLED)
        enrolled = search_enrolled(user, enrolled_search_context)
        unenrolled_search_context = search_context_with_type(search_context, SearchContext::UNENROLLED)
        unenrolled = search_unenrolled(user, unenrolled_search_context)

        enrolled.merge(unenrolled)
      elsif search_context.search_enrolled_courses?
        search_enrolled(user, search_context)
      elsif search_context.search_unenrolled_courses?
        search_unenrolled(user, search_context)
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

    def search_enrolled(user, ctx)
      enrolled = FilterService.new(user, ctx).filter

      {
        enrolled_courses: enrolled.records,
        enrolled_courses_count: enrolled.count
      }
    end

    def search_unenrolled(user, ctx)
      unenrolled = FilterService.new(user, ctx).filter
      {
        available_courses: unenrolled.records,
        available_courses_count: unenrolled.count
      }
    end

    def search_all(user, ctx)
      all = FilterService.new(user, ctx).filter
      {
        available_courses: all.records,
        available_courses_count: all.count
      }
    end
  end
end
