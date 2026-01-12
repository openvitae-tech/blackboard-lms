# frozen_string_literal: true

module ViewComponent
  # To be used only within a component class such as ButtonComponent
  module ComponentHelper
    def class_list(base, *styles)
      base.concat(styles.compact)
      base.join(' ')
    end

    def resolve_error(form, name, explicit_error)
      return explicit_error if explicit_error.present?
      return if form.blank?

      attribute = name.to_s.split('[').last.delete(']').humanize
      message = form.object.errors[name].first

      message.present? ? "#{attribute} #{message}" : nil
    end
  end
end
