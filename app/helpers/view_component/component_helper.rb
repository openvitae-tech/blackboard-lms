# frozen_string_literal: true

module ViewComponent
  module ComponentHelper
    def class_list(base, *styles)
      base.concat(styles.compact)
      base.join(' ')
    end

    def resolve_error(form, name, explicit_error)
      return explicit_error if explicit_error.present?

      errors = form&.object&.errors
      errors&.[](name)&.first
    end
  end
end
