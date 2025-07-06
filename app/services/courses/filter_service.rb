# frozen_string_literal: true

module Courses
  class FilterService
    attr_reader :user, :search_context

    def initialize(user, search_context)
      @user = user
      @search_context = search_context
      raise Errors::IllegalSearchContext, 'Search context is blank' if user.blank? || search_context.blank?
    end

    def filter
      course_scope = filter_scope_for(user, search_context)
      course_scope = filter_by_matching_term(course_scope, search_context)
      course_scope = filter_by_tags(search_context.tags, course_scope)

      course_scope = if search_context.team_assign?
                       filter_out_team_enrolled_courses(course_scope, search_context)
                     elsif search_context.user_assign?
                       filter_out_user_enrolled_courses(course_scope, search_context)
                     else
                       course_scope
                     end

      SearchResult.new(course_scope, search_context)
    end

    private

    def filter_by_tags(tags, courses)
      return courses if tags.blank?

      levels, categories = fetch_levels_and_categories_for(tags)

      if categories.present? && levels.present?
        courses.left_joins(:tags)
               .where(tags: { id: categories })
               .where(id: Course.left_joins(:tags)
                                .where(tags: { id: levels })
                                .select(:id))
      elsif categories.present?
        courses.left_joins(:tags)
               .where(tags: { id: categories })
      elsif levels.present?
        courses.left_joins(:tags)
               .where(tags: { id: levels })
      else
        courses
      end
    end

    def filter_by_matching_term(scope, search_context)
      return scope if search_context.term.blank?

      scope.where('title ILIKE ?', "%#{search_context.term}%")
    end

    def filter_out_team_enrolled_courses(scope, search_context)
      enrolled_courses_ids = search_context.team.team_enrollments.pluck(:course_id)
      scope.where.not(id: enrolled_courses_ids)
    end

    def filter_out_user_enrolled_courses(scope, search_context)
      enrolled_courses_ids = search_context.user.enrollments.pluck(:course_id)
      scope.where.not(id: enrolled_courses_ids).order(:id)
    end

    def filter_scope_for(user, search_context)
      scope = if search_context.search_enrolled_courses?
                user.courses
              elsif search_context.search_unenrolled_courses?
                Course.where.not(
                  id: Enrollment.where(user_id: user.id).select(:course_id)
                )
              else
                Course.all
              end

      scope = scope.published unless user.is_admin?

      scope.includes(%i[banner_attachment tags])
           .order(created_at: :desc)
           .limit(Course::PER_PAGE_LIMIT)
    end

    def fetch_levels_and_categories_for(tags)
      records = Tag.where(name: tags).pluck(:id, :tag_type)

      categories = records.filter { |_id, tag_type| tag_type == 'category' }.map { |id, _tag_type| id }
      levels = records.filter { |_id, tag_type| tag_type == 'level' }.map { |id, _tag_type| id }

      [levels, categories]
    end
  end
end
