class CoursePolicy
  attr_reader :user, :course

  def initialize(user, course)
    @user = user
    @course = course
  end

  def new?
    user.is_admin?
  end

  def create?
    user.is_admin?
  end

  def show?
    user.present?
  end

  def update?
    user.is_admin?
  end

  def edit?
    user.is_admin?
  end

  def destroy?
    user.is_admin?
  end

  def enroll?
    user.present? && !user.enrolled_for_course?(course)
  end

  def unenroll?
    user.present? && user.enrolled_for_course?(course)
  end

  def proceed?
    user.present? && user.enrolled_for_course?(course)
  end

  def complete?
    user.present? && user.enrolled_for_course?(course)
  end
end