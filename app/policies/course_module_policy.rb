# frozen_string_literal: true

class CourseModulePolicy < ApplicationPolicy
  attr_reader :user, :course_module

  def initialize(user, record)
    @user = user
    @course_module = record
  end

  def new?
    user.is_admin?
  end

  def show?
    user.is_admin?
  end

  def create?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end

  def edit?
    user.is_admin?
  end

  def destroy?
    CoursePolicy.new(user, course_module.course).destroy?
  end

  def moveup?
    user.is_admin?
  end

  def movedown?
    user.is_admin?
  end

  def summary?
    true
  end
end
