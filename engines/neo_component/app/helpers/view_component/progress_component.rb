# frozen_string_literal: true

module ViewComponent
  module ProgressComponent
    def progressbar_component(numerator: nil, denominator: nil, value: nil, color: :primary)
      fill = if value
               value.to_i.clamp(0, 100)
             elsif numerator.blank? || denominator.blank? || denominator.to_f.zero?
               0
             else
               (numerator / denominator.to_f * 100).to_i
             end
      render partial: 'view_components/progress_component/progressbar',
             locals: { numerator:, denominator:, fill:, color:, full_width: value.present? }
    end
  end
end
