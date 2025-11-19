# frozen_string_literal: true

module ViewComponent
  module ProgressComponent
    def progressbar_component(numerator:, denominator:)
      numerator = 0 if numerator.blank?
      denominator = 0 if denominator.blank?
      fill = denominator.zero? ? 0 : (numerator / denominator.to_f * 100).to_i
      render partial: 'view_components/progress_component/progressbar', locals: { numerator:, denominator:, fill: }
    end
  end
end
