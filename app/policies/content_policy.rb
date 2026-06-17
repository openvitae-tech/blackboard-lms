# frozen_string_literal: true

class ContentPolicy
  attr_reader :user, :record

  def initialize(user, _record)
    @user = user
  end

  def index?
    user.privileged_user?
  end
end
