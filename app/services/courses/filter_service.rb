# frozen_string_literal: true

class Courses::FilterService
  include Singleton

  def filter_courses(current_user, tags, search_term)
   courses =  filter_by_search(current_user, search_term)
    if current_user.is_admin?
      admin_courses(tags, courses)
    else
      non_admin_courses(tags, courses)
    end
  end

  private

  def admin_courses(tags, courses)
   filtered_courses = filter_by_tags(tags, courses)
    {
      available_courses: filtered_courses.limit(10),
      available_courses_count: filtered_courses.length
    }
  end

  def non_admin_courses(tags, courses)
    filtered_available_courses = filter_by_tags(tags, courses[:current_user_available_courses])
    filtered_enrolled_courses = filter_by_tags(tags, courses[:current_user_enrolled_courses])
    enrolled_course_ids = filtered_enrolled_courses.pluck(:id)
    {
      enrolled_courses: filtered_enrolled_courses.limit(2),
      available_courses: filtered_available_courses.where.not(id: enrolled_course_ids).limit(10),
      enrolled_courses_count: filtered_enrolled_courses.length,
      available_courses_count: filtered_available_courses.where.not(id: enrolled_course_ids).length
    }

  end

  def filter_by_tags(tags, courses)
    return courses unless tags.present?

    categories = Tag.where(tag_type: :category, name: tags).pluck(:id)
    levels = Tag.where(tag_type: :level, name: tags).pluck(:id)

    if categories.present? && levels.present?
      courses.joins(:tags)
             .where(tags: { id: categories })
             .where(id: Course.joins(:tags).where(tags: { id: levels }).select(:id))
    elsif categories.present?
      courses.joins(:tags)
             .where(tags: { id: categories })
    elsif levels.present?
      courses.joins(:tags)
             .where(tags: { id: levels })
    else
      courses
    end
  end

  def filter_by_search(current_user, search_term)
    service = CourseManagementService.instance
    service.search(current_user, search_term)
  end
end
