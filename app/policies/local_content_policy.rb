# frozen_string_literal: true

class LocalContentPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @local_content = record
  end

  def retry?
    user.is_admin?
  end
end
