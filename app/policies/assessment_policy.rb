# frozen_string_literal: true

class AssessmentPolicy
  attr_reader :user, :assessment

  def initialize(user, record)
    @user = user
    @assessment = record
  end

  def show?
    user == @assessment.user
  end

  def update?
    user == @assessment.user
  end

  def retry?
    user == @assessment.user
  end

  def result?
    user == @assessment.user
  end
end
