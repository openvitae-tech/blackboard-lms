module CustomValidations
  extend ActiveSupport::Concern

  included do
    def acceptable_logo
      return unless logo.attached?

      unless logo.blob.byte_size <= 1.megabyte
        errors.add(:logo, "is too big")
      end
    end

    def acceptable_banner
      return unless banner.attached?

      unless banner.blob.byte_size <= 1.megabyte
        errors.add(:banner, "is too big")
      end
    end
  end

  class_methods do

  end
end