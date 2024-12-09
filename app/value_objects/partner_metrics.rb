# frozen_string_literal: true

# PORO class for partner metrics
class PartnerMetrics

  attr_reader :partner

  def initialize(partner)
    @partner = partner
    @course_enrollment_counts = {}
  end

  def course_enrollment_counts_for(course)
    course_enrollment_counts.fetch(course.id, 0)
  end

  def course_enrollment_counts
    return @course_enrollment_counts if @course_enrollment_counts.present?

    results = course_enrollment_query.call
    grouped_events = results.group_by { |event| event.data["course_id"] }
    grouped_events.each do |key, value|
      @course_enrollment_counts[key] = value.count
    end

    @course_enrollment_counts
  end

  private

  def course_enrollment_query
    @user_enrolled_query ||= UserEnrolledQuery.new(partner.id, nil)
  end
end
