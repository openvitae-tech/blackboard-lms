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

    private

    def require_content_studio_access!
      redirect_to root_path unless ContentStudio.authorization_callback.call(try(:current_user))
    end
  end
end
