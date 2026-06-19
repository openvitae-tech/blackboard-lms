# frozen_string_literal: true

class CoursePolicy
  include CourseVisibilityHelper

  attr_reader :user, :course

  def initialize(user, course)
    @user = user
    @course = course
  end

  def index?
    user.present?
  end

  def manage?
    user.is_admin? || (user.privileged_user? && user.learning_partner.content_studio_enabled?)
  end

  def continue?
    !user.is_admin?
  end

  def complete?
    !user.is_admin?
  end

  def new?
    user.is_admin?
  end

  def create?
    user.is_admin?
  end

  def show?
    return true if user.is_admin?
    return true if user.privileged_user? && partner_cs_course?

    return false unless visible_course?(course)

    @course.published? || user.enrolled_for_course?(course)
  end

  def update?
    user.is_admin?
  end

  def edit?
    user.is_admin?
  end

  def destroy?
    user.is_admin? && !course.published? && !course.enrollments_present?
  end

  def enroll?
    return false unless visible_course?(course)

    !user.is_admin? && !user.enrolled_for_course?(course)
  end

  def unenroll?
    # once enrolled a course cannot be dropped by users in production
    # but this will be very useful for testing
    return false if Rails.env.production?

    !user.is_admin? && user.enrolled_for_course?(course)
  end

  def proceed?
    return false unless user.enrolled_for_course?(course)

    enrollment = user.get_enrollment_for(course)
    !enrollment.course_completed?
  end

  def publish?
    return false if course.published?
    return false unless user.is_admin? || (user.privileged_user? && own_content_studio_course?)

    course.ready_to_publish?
  end

  def unpublish?
    (user.is_admin? || (user.privileged_user? && own_content_studio_course?)) && course.published?
  end

  def search?
    user.present?
  end

  def explore?
    user.present?
  end

  private

  def partner_cs_course?
    user.learning_partner.content_studio_enabled? &&
      course.neo_ai_course_id.present? &&
      course.learning_partner_id == user.learning_partner_id
  end

  def own_content_studio_course?
    content_studio_access? &&
      course.neo_ai_course_id.present? &&
      course.learning_partner_id == user.learning_partner_id
  end

  def content_studio_access?
    user.content_studio_creator? && user.learning_partner.content_studio_enabled?
  end
end
