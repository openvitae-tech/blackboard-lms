# frozen_string_literal: true

module ScormEngine
  class Course
    def initialize
      raise 'Cannot initialize an abstract Course class'
    end

    def title
      raise NotImplementedError, "#{self.class} must implement abstract method 'title'"
    end

    def description
      raise NotImplementedError, "#{self.class} must implement abstract method 'description'"
    end

    def course_modules
      raise NotImplementedError, "#{self.class} must implement abstract method 'course_modules'"
    end
  end
end
