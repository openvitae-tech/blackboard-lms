# frozen_string_literal: true

module CourseNavContext
  extend ActiveSupport::Concern

  included do
    before_action -> { @active_nav = 'courses' }
  end
end
