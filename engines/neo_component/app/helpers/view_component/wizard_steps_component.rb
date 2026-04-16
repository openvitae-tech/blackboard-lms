# frozen_string_literal: true

module ViewComponent
  module WizardStepsComponent
    class WizardStepsComponent
      include ViewComponent::ComponentHelper

      Step = Struct.new(:icon_name, :label, :state, keyword_init: true) do
        def active?    = state == :active
        def completed? = state == :completed
        def upcoming?  = state == :upcoming
      end

      attr_accessor :steps

      def initialize(steps:, current_step:)
        raise ArgumentError, 'steps must be a non-empty Array' unless steps.is_a?(Array) && steps.any?
        raise ArgumentError, 'current_step must be an Integer' unless current_step.is_a?(Integer)

        self.steps = steps.each_with_index.map do |step, index|
          state = if index == current_step
                    :active
                  elsif index < current_step
                    :completed
                  else
                    :upcoming
                  end
          Step.new(icon_name: step[:icon_name], label: step[:label].to_s, state:)
        end
      end

      def step_circle_class(step)
        if step.active?
          'bg-primary-light-100 border-2 border-primary text-primary'
        elsif step.completed?
          'bg-primary-light-100 border border-slate-grey-light text-slate-grey-50'
        else
          'bg-white border border-slate-grey-light text-slate-grey-50'
        end
      end

      def step_label_class(step)
        if step.active? || step.completed?
          'general-text-sm-medium text-letter-color'
        else
          'general-text-sm-normal text-letter-color-light'
        end
      end
    end

    def wizard_steps_component(steps:, current_step:)
      component = WizardStepsComponent.new(steps:, current_step:)
      render partial: 'view_components/wizard_steps_component/wizard_steps', locals: { component: }
    end
  end
end
