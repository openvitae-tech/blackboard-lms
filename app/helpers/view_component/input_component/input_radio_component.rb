# frozen_string_literal: true

module ViewComponent
  module InputComponent
    class InputRadioComponent
      include ViewComponent::ComponentHelper

      attr_accessor :form, :name, :label, :value, :disabled, :error, :label_position, :html_options

      def initialize(form:, name:, label:, value:, disabled:, error:, label_position:, html_options:)
        self.form = form
        self.name = name
        self.label = label
        self.label_position = label_position
        self.value = value
        self.html_options = html_options
        self.disabled = disabled
        self.html_options[:disabled] = disabled
        self.html_options[:class] = 'hidden'
        self.error = resolve_error(form, name, error)
      end

      def label_style
        if disabled
          'text-disabled-color'
        elsif error
          'text-danger-dark'
        else
          'text-letter-color group-has-[input:checked]:text-primary group-hover:text-primary-light'
        end
      end

      def radio_circle_style
        if disabled
          'border-disabled-color'
        elsif error
          'border-danger-dark'
        else
          'border-slate-grey-50 group-hover:border-primary-light group-has-[input:checked]:border-primary'
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
