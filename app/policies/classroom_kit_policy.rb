# frozen_string_literal: true

class ClassroomKitPolicy
  attr_reader :user, :classroom_kit

  def initialize(user, classroom_kit)
    @user = user
    @classroom_kit = classroom_kit
  end

  def index?
    user.privileged_user?
  end

  def show?
    user.privileged_user?
  end

  def save?
    user.content_studio_creator?
  end
end
