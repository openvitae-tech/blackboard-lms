# frozen_string_literal: true

module QuestionsHelper
  def current_tab
    params[:tab] || 'all'
  end

  def tab_name_with_count(key, count)
    QuestionsBank::TABS[key] + "(#{count})"
  end

  def tab_keys
    QuestionsBank::TABS.keys
  end

  def tab_style(tab_key)
    tab_name = tab_key.to_s
    if tab_name == params[:tab] || ((params[:tab].nil? || !params[:tab].to_sym.in?(tab_keys)) && tab_name == 'all')
      'bg-secondary-dark text-white rounded-t-lg'
    else
      'border-b border-secondary'
    end
  end

  def question_body_id(question)
    dom_id(question).concat '_body'
  end
end
