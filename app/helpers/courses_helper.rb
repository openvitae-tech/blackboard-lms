module CoursesHelper
  def course_banner(course)
    return course.banner if course && course.banner.present?

    "course.jpeg"
  end

  def course_banner_thumbnail(course)
    return course.banner if course && course.banner.variant(resize_to_limit: [nil, 200])

    "course_thumbnail.jpeg"
  end
end
