# frozen_string_literal: true

# PORO class for partner metrics
# naming use _value for any resulting single value such as counts
# for multiple items in the results use _values
class PartnerMetrics

  attr_reader :partner

  COUNTS = [
    :onboarding_initiated_count,
    :user_login_count,
    :user_logout_count,
    :first_owner_joined_count,
    :user_invited_count,
    :user_joined_count,
    :user_enrolled_count,
    :course_started_count,
    :course_completed_count,
    :course_views_count,
    :lesson_views_count,
  ]

  def initialize(partner)
    @partner = partner
    @course_enrollment_values = {}
    @time_spent_total = nil
  end

  def course_enrollment_counts_for(course)
    course_enrollment_values.fetch(course.id, 0)
  end

  def course_enrollment_values
    return @course_enrollment_values if @course_enrollment_values.present?

    query = init_query_object('user_enrolled_query')
    results = query.call
    grouped_events = results.group_by { |event| event.data["course_id"] }
    grouped_events.each do |key, value|
      @course_enrollment_values[key] = value.count
    end

    @course_enrollment_values
  end

  def onboarding_initiated?
    onboarding_initiated_count > 0
  end

  def first_owner_joined?
    first_owner_joined_count > 0
  end
  # dynamically define counter methods
  COUNTS.each do |count_name|
      define_method count_name do
        value = instance_variable_get("@#{count_name.to_s}")
        return value if value.present?

        # eg: course_views_count_query
        query_object_name = count_name.to_s.sub('_count', '_query')

        query = init_query_object(query_object_name)

        value = query.call.count
        instance_variable_set("@#{count_name[1..]}".to_sym, value)
        value
      end
    end

  def time_spent_total
    return @time_spent_total if @time_spent_total
    query = init_query_object('time_spent_query')
    @time_spent_total = query.call.map { |x| x.data['time_spent'] }.sum
  end

  private

  # Here code uses metaprogramming and is confined to private scope to avoid confusion.
  # For each `query_object_name` a corresponding query class is expected in app/queries.
  # For example a query class TimeSpentQuery exists for `time_spent_query` object.
  # The corresponding query object is instantiated using meta programming and is cached in an instance variable
  # ending with '_query' to avoid duplicate instantiation.
  def init_query_object(query_object_name)
    value = instance_variable_get("@#{query_object_name}")
    return value if value.present?

    klass_name = query_object_name.camelize
    klass = Kernel.const_get(klass_name)
    instance_variable_set("@#{query_object_name}", klass.new(partner.id, nil))
  end
end