# frozen_string_literal: true

class UserStatisticsService
  include Singleton

  UserStatistics = Struct.new(:no_courses_enrolled, :total_time_spent, :user_score)
  def build_stats_for(user)
    no_courses_enrolled = user.enrollments.size
    total_time_spent = (user.enrollments.map(&:time_spent).reduce(:+) || 0) / 1000 # time spent in minutes
    user_score = 0
    UserStatistics.new(no_courses_enrolled, total_time_spent, user_score)
  end
end
