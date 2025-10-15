# frozen_string_literal: true

module ViewComponent
  module InputComponent
    class InputRadioComponent
      include ViewComponent::ComponentHelper

      attr_accessor :form, :name, :label, :value, :disabled, :error, :html_options

      def initialize(form:, name:, label:, checked:, disabled:, error:, html_options:)
        self.form = form
        self.name = name
        self.label = label
        self.value = checked ? '1' : '0'
        self.html_options = html_options
        self.disabled = disabled
        self.html_options[:disabled] = disabled
        self.html_options[:class] = 'hidden peer'
        self.error = resolve_error(form, name, error)
      end

      def label_style
        if disabled
          'text-disabled-color'
        elsif error
          'text-danger-dark group-hover:text-danger'
        else
          'text-letter-color group-hover:text-primary-light'
        end
      end

      def radio_circle_style
        if disabled
          'border-disabled-color'
        elsif error
          'border-danger-dark group-hover:border-danger'
        else
          'border-letter-color group-hover:border-primary-light peer-checked:border-primary-light'
        end
      end

      def radio_dot_style
        if disabled
          'bg-white'
        elsif error
          'group-has-[input:checked]:bg-danger-dark'
        else
          'group-has-[input:checked]:bg-primary'
        end
      end
    end
  end
end
