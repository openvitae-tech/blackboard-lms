# frozen_string_literal: true

module ViewComponent
  module ComponentHelper
    def class_list(base, *styles)
      base.concat(styles.compact)
      base.join(' ')
    end

    def resolve_error(form, name, explicit_error)
      errors = form&.object&.errors
      form_error = errors&.[](name)&.first
      form_error.presence || explicit_error
    end
  end
end
