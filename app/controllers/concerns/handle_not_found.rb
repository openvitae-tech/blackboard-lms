module HandleNotFound
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::UnknownFormat, with: :not_found

    before_action :set_default_format, only: [:not_found]

    def not_found
      if request.format != :html
        render status: :not_found, plain: "Not found"
      else
        render template: "pages/not_found", status: :not_found
      end
    end

    private

    def set_default_format
      request.format = :html
    end
  end
end
