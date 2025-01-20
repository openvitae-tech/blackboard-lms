# frozen_string_literal: true

module ScormEngine
  class Lesson
    def initialize
      raise 'Cannot initialize an abstract Lesson class'
    end

    def title
      raise NotImplementedError, "#{self.class} must implement abstract method 'title'"
    end

    def videos
      raise NotImplementedError, "#{self.class} must implement abstract method 'videos'"
    end
  end
end
