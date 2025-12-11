# frozen_string_literal: true

module CustomValidations
  extend ActiveSupport::Concern

  MATERIAL_CONTENT_TYPES = %w[application/pdf].freeze
  MATERIAL_MAX_MB = 10

  included do
    def acceptable_logo
      acceptable_image('logo')
    end

    def acceptable_banner
      acceptable_image('banner')
    end

    def acceptable_materials
      materials.each do |material|
        unless material.content_type.in?(MATERIAL_CONTENT_TYPES)
          errors.add(:base,
                     'Course material must be a PDF document')
        end
        if material.byte_size > MATERIAL_MAX_MB.megabytes
          errors.add(:base, "Course material must be less than #{MATERIAL_MAX_MB}MB")
        end
      end
    end

    private

    def acceptable_image(field_name)
      # here access the image field by name
      image_field = send(field_name)
      return unless image_field.attached?

      acceptable_types = %w[image/jpeg image/png image/jpg]

      unless acceptable_types.include?(image_field.content_type)
        errors.add(field_name.to_sym, 'must be a JPEG, JPG or PNG')
      end

      return if image_field.blob.byte_size <= 1.megabyte

      errors.add(field_name.to_sym, 'is too big')
    end

    def dob_within_valid_age_range
      return if dob.blank?

      min_age = 16
      max_age = 80
      today = Time.zone.today
      age = today.year - dob.year

      if age < min_age
        errors.add(:dob, "Age must be at least #{min_age} years old.")
      elsif age > max_age
        errors.add(:dob, "Age must be at most #{max_age} years old.")
      end
    end
  end
end
