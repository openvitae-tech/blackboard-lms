# frozen_string_literal: true

module AssessmentHelper
  def result_styles(is_pass)
    if is_pass
      { grid_bg: 'bg-secondary-dark', grid_item_bg: 'bg-secondary-light' }
    else
      { grid_bg: 'bg-danger', grid_item_bg: 'bg-danger-light' }
    end
  end

  def start_btn_text(attempt)
    attempt == 1 ? t('assessment.start') : t('assessment.restart')
  end

  def render_nav_button(item, assessment)
    base_classes = 'h-10 w-10 flex items-center justify-center rounded-lg main-text-sm-normal \
                    transition-colors border border-slate-grey-light'
    status_classes = case item[:status]
                     when :current then 'bg-primary text-white shadow-md'
                     when :answered then 'bg-secondary-light text-primary'
                     when :skipped then 'bg-white text-primary'
                     else 'bg-primary-light-100 text-disabled-color'
                     end

    button_to (item[:index] + 1), assessment_path(id: assessment.encoded_id),
              method: :patch,
              params: { jump_to_index: item[:index] },
              class: "#{base_classes} #{status_classes}"
  end
end
