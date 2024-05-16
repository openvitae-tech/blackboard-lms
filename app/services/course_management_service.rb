class CourseManagementService
  include Singleton
  def enroll(user, course)
    return :duplicate if user.enrolled_for_course?(course)
    course.enroll(user)
    :ok
  end

  def undo_enroll(user, course)
    return :not_enrolled unless user.enrolled_for_course?(course)
    course.undo_enroll(user)
    :ok
  end

  def search(term)
    Course.where("title ilike ?", "%#{term}%")
  end
end