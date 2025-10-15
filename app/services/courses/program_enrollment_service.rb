# frozen_string_literal: true

module Courses
  class ProgramEnrollmentService
    def initialize(user, program)
      @user = user
      @program = program
    end

    def enroll!
      service = CourseManagementService.instance

      ActiveRecord::Base.transaction do
        @program.program_users.create!(user: @user) unless already_enrolled?

        @program.courses.each do |course|
          service.enroll!(@user, course)
        end
      end
    end

    private

    def already_enrolled?
      @program.program_users.exists?(user: @user)
    end
  end
end
