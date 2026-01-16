# frozen_string_literal: true

# PORO class for Questions Bank
class QuestionsBank
  TABS = { all: 'All', verified: 'Verified', unverified: 'Unverified', reported: 'Reported' }.freeze

  TABS.each_key { |key| attr_reader key.to_sym }

  def initialize(questions)
    @all = questions
    @verified = questions.verified
    @unverified = questions.unverified
    @reported = questions.reported
  end

  def per_page(tab, page)
    send(tab).page(page)
  end

  def count(tab)
    send(tab).count
  end
end
