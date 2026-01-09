# frozen_string_literal: true

module ViewComponent
  # To be used only within a component class such as ButtonComponent
  module ComponentHelper
    def class_list(base, *styles)
      base.concat(styles.compact)
      base.join(' ')
    end

    def resolve_error(form, name, explicit_error)
      attribute =
        name.to_s
            .split('[').last
            .delete(']')
            .humanize

      return "#{attribute} #{explicit_error}" if explicit_error.present?

      errors = form&.object&.errors
      message = errors&.[](name)&.first

      message.present? ? "#{attribute} #{message}" : nil
    end
  end
end
