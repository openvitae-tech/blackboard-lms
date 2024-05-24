module CustomValidations
  extend ActiveSupport::Concern

  included do
    def acceptable_logo
      acceptable_image("logo")
    end

    def acceptable_banner
      acceptable_image("banner")
    end

    private
    def acceptable_image(field_name)
      # here access the image field by name
      image_field = send(field_name)
      return unless image_field.attached?

      acceptable_types = %w(image/jpeg image/png image/jpg)

      unless acceptable_types.include?(image_field.content_type)
        errors.add(field_name.to_sym, "must be a JPEG, JPG or PNG")
      end


      unless image_field.blob.byte_size <= 1.megabyte
        errors.add(field_name.to_sym, "is too big")
      end
    end
  end

  class_methods do

  end
end