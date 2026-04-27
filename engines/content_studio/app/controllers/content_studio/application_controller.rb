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
  end
end
