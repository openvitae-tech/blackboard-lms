# frozen_string_literal: true

class Courses::FilterService
  include Singleton

  def filter_courses(current_user, tags, search_term = "", type = "")
   courses =  filter_by_search(current_user, search_term)
    if current_user.is_admin?
      admin_courses(tags, courses)
    else
      non_admin_courses(tags, courses, type)
    end
  end

  private

  def admin_courses(tags, courses)
   filtered_courses = filter_by_tags(tags, courses)
    {
      available_courses: filtered_courses.includes(:banner_attachment, :tags).limit(10),
      available_courses_count: filtered_courses.length
    }
  end

  def non_admin_courses(tags, courses, type)
    filtered_available = filter_by_tags(tags, courses[:current_user_available_courses])
    filtered_enrolled = filter_by_tags(tags, courses[:current_user_enrolled_courses])
    available_excluding_enrolled = filtered_available.where.not(id: filtered_enrolled.pluck(:id))
    {
      enrolled_courses: (type != 'all' ? filtered_enrolled.includes(:banner_attachment, :tags).limit(2) : []),
      available_courses: (type != 'enrolled' ? available_excluding_enrolled.includes(:banner_attachment, :tags).limit(10) : []),
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

  def filter_by_search(current_user, search_term)
    service = CourseManagementService.instance
    service.search(current_user, search_term)
  end
end
