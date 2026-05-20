# frozen_string_literal: true

module ContentStudio
  module HostRoutesHelper
    def method_missing(method, ...)
      main_app.respond_to?(method) ? main_app.public_send(method, ...) : super
    end

    def respond_to_missing?(method, include_private = false)
      main_app.respond_to?(method) || super
    end
  end

  class ApplicationController < ContentStudio.parent_controller.constantize
    helper HostRoutesHelper
    before_action :require_content_studio_access!
    before_action { ApiClient.current_cookie = request.env['HTTP_COOKIE'] }
    after_action { ApiClient.current_cookie = ApiClient.cached_client = ApiClient.cached_client_cookie = nil }

    private

    def authenticate_user!
      redirect_to main_app.new_login_path unless user_signed_in?
    end

    def require_content_studio_access!
      redirect_to '/' unless ContentStudio.authorization_callback.call(try(:current_user))
    end
  end
end
