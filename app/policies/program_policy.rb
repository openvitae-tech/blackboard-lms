# frozen_string_literal: true

class ProgramPolicy
  attr_reader :user, :program

  def initialize(user, record)
    @user = user
    @program = record
  end

  def index?
    user.privileged_user?
  end

  def new?
    user.privileged_user?
  end

  def create?
    user.privileged_user?
  end

  def show?
    user.privileged_user?
  end

  def edit?
    user.privileged_user?
  end

  def update?
    user.privileged_user?
  end

  def add_courses?
    user.privileged_user?
  end

  def create_courses?
    user.privileged_user?
  end

  def destroy?
    user.privileged_user?
  end

  def confirm_destroy?
    user.privileged_user?
  end

  def confirm_bulk_destroy_courses?
    user.privileged_user?
  end

  def bulk_destroy_courses?
    user.privileged_user?
  end

  def list?
    user.is_learner? && user.learning_partner.programs.exists?
  end

  def choose?
    user.is_learner? && user.learning_partner.programs.exists?
  end
end
