# frozen_string_literal: true

module CourseVisibilityHelper
  extend ActiveSupport::Concern

  def visible_course?(record)
    return true if user.is_admin?
    return true unless user.learning_partner.is_public?

    record.visibility == 'public'
  end
end
