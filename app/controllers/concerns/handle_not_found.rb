module HandleNotFound
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    before_action :set_default_format, only: [:not_found]

    def not_found
      render template: "pages/not_found", layout: false, status: :not_found
    end

    private

    def set_default_format
      request.format = :html unless request.format == :json
    end
  end
end
