# frozen_string_literal: true

# PORO class for partner metrics
# naming use _value for any resulting single value such as counts
# for multiple items in the results use _values
class PartnerMetrics

  attr_reader :partner

  def initialize(partner)
    @partner = partner
    @course_enrollment_values = {}
    @user_invited_value = nil
    @user_joined_value = nil
    @course_enrolled_value = nil
    @course_started_value = nil
    @course_completed_value = nil
    @course_views_value = nil
    @lesson_views_value = nil
    @time_spent_value = nil
  end

  def course_enrollment_counts_for(course)
    course_enrollment_values.fetch(course.id, 0)
  end

  def course_enrollment_values
    return @course_enrollment_values if @course_enrollment_values.present?

    results = user_enrolled_query.call
    grouped_events = results.group_by { |event| event.data["course_id"] }
    grouped_events.each do |key, value|
      @course_enrollment_values[key] = value.count
    end

    @course_enrollment_values
  end

  def user_invited_value
    return @user_invited_value if @user_invited_value.present?
    @user_invited_value = user_invited_query.call.count
  end

  def user_joined_value
    return @user_joined_value if @user_joined_value.present?
    @user_joined_value = user_joined_query.call.count
  end

  def course_enrolled_value
    return @course_enrolled_value if @course_enrolled_value.present?
    @course_enrolled_value = user_enrolled_query.call.count
  end

  def course_started_value
    return @course_started_value if @course_started_value.present?
    @course_started_value = course_started_query.call.count
  end

  def course_completed_value
    return @course_completed_value if @course_completed_value
    @course_completed_value = course_completed_query.call.count
  end

  def course_views_value
    return @course_views_value if @course_views_value.present?
    @course_views_value = course_views_query.call.count
  end

  def lesson_views_value
    return @lesson_views_value if @lesson_views_value.present?
    @lesson_views_value = lesson_views_query.call.count
  end

  def time_spent_value
    return @time_spent_value if @time_spent_value
    @time_spent_value = time_spent_query.call.map { |x| x.data['time_spent'] }.sum
  end

  private

  def user_enrolled_query
    @user_enrolled_query ||= UserEnrolledQuery.new(partner.id, nil)
  end

  def user_invited_query
    @user_invited_query ||= UserInvitedQuery.new(partner.id, nil)
  end

  def user_joined_query
    @user_joined_query ||= UserJoinedQuery.new(partner.id, nil)
  end

  def course_started_query
    @course_started_query ||= CourseStartedQuery.new(partner.id, nil)
  end

  def course_completed_query
    @course_completed_query ||= CourseCompletedQuery.new(partner.id, nil)
  end

  def course_views_query
    @course_views_query ||= CourseViewsQuery.new(partner.id, nil)
  end

  def lesson_views_query
    @lesson_views_query ||= LessonViewsQuery.new(partner.id, nil)
  end

  def time_spent_query
    @time_spent_query ||= TimeSpentQuery.new(partner.id, nil)
  end
end