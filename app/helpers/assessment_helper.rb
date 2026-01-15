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
end
