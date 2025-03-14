# frozen_string_literal: true

module Impersonation
  extend ActiveSupport::Concern

  private

  def fetch_impersonated_user(id)
    REDIS_CLIENT.call("GET", "impersonated_support_user_#{id}")
  end

  def destroy_impersonation(id)
    REDIS_CLIENT.call("DEL", "impersonated_support_user_#{id}")
  end

  def store_impersonated_user(id, data)
    REDIS_CLIENT.call("SET", "impersonated_support_user_#{id}", data)
  end
end
