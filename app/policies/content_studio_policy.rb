# frozen_string_literal: true

class ContentStudioPolicy
  attr_reader :user, :record

  def initialize(user, _record)
    @user = user
    @record = record
  end

  def index?
    user.content_studio_creator? && user.learning_partner.content_studio_enabled?
  end
end
