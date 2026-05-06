# frozen_string_literal: true

module ViewComponent
  module ProgressComponent
    def progressbar_component(numerator: nil, denominator: nil, value: nil, color: :primary, segments: nil, full_width: nil, animated: false, thin: false)
      fill = if segments
               nil
             elsif value
               value.to_i.clamp(0, 100)
             elsif numerator.blank? || denominator.blank? || denominator.to_f.zero?
               0
             else
               (numerator / denominator.to_f * 100).to_i
             end
      resolved_full_width = full_width.nil? ? (value.present? || segments.present?) : full_width
      render partial: 'view_components/progress_component/progressbar',
             locals: { numerator:, denominator:, fill:, color:, segments:, full_width: resolved_full_width, animated:, thin: }
    end
  end
end
