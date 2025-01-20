# frozen_string_literal: true

module ScormEngine
  class CourseModule
    def initialize
      raise 'Cannot initialize an abstract CourseModule class'
    end

    def title
      raise NotImplementedError, "#{self.class} must implement abstract method 'title'"
    end

    def lessons
      raise NotImplementedError, "#{self.class} must implement abstract method 'lessons'"
    end
  end
end
