# frozen_string_literal: true

class Courses::FilterService
  include Singleton

  def filter_courses(user, tags, search_term = "", type = "")
    courses = filter_by_term(user, search_term)

    if user.is_admin?
      admin_courses(tags, courses)
    else
      non_admin_courses(tags, courses, type)
    end
  end

  def filter(user, search_context)
    course_scope = filter_scope_for(user)
    course_scope = filter_by_matching_term(course_scope, search_context)
    course_scope = filter_by_tags(search_context.tags, course_scope)

    if search_context.team_assign?
      filter_out_team_enrolled_courses(course_scope, search_context)
    elsif search_context.user_assign?
      filter_out_user_enrolled_courses(course_scope, search_context)
    else
      course_scope
    end
  end

  private

  def admin_courses(tags, courses)
    filtered_courses = filter_by_tags(tags, courses)
    {
      available_courses: filtered_courses.includes(:banner_attachment, :tags).limit(Course::PER_PAGE_LIMIT),
      available_courses_count: filtered_courses.length
    }
  end

  def non_admin_courses(tags, courses, type)
    filtered_available = filter_by_tags(tags, courses[:current_user_available_courses])
    filtered_enrolled = filter_by_tags(tags, courses[:current_user_enrolled_courses])
    available_excluding_enrolled = filtered_available.where.not(id: filtered_enrolled.pluck(:id))
    {
      enrolled_courses: (type != 'all' ? filtered_enrolled.includes(:banner_attachment, :tags).limit(Course::ENROLLED_COURSES_LIMIT) : []),
      available_courses: (type != 'enrolled' ? available_excluding_enrolled.includes(:banner_attachment, :tags).limit(Course::PER_PAGE_LIMIT) : []),
      enrolled_courses_count: (type != 'all' ? filtered_enrolled.size : 0),
      available_courses_count: (type != 'enrolled' ? available_excluding_enrolled.size : 0)
    }
  end

  def filter_by_tags(tags, courses)
    return courses unless tags.present?

    categories = Tag.where(tag_type: :category, name: tags).pluck(:id)
    levels = Tag.where(tag_type: :level, name: tags).pluck(:id)

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

  def filter_by_term(user, term)
    courses_scope = Course.where('title ILIKE ?', "%#{term}%").order(created_at: :desc)

    if user.is_admin?
      courses_scope
    else
      {
        current_user_enrolled_courses: user.courses.merge(courses_scope),
        current_user_available_courses: courses_scope.published
      }
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

  def filter_scope_for(user)
    all_courses = Course.includes([:banner_attachment]).order(created_at: :desc)

    if user.is_admin?
      all_courses
    else
      all_courses.published
    end
  end
end
