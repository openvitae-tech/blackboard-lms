# frozen_string_literal: true

class SearchContext
  include ActiveModel::API

  # pass from where the SearchContext is initialized
  VALID_CONTEXTS = %i[home_page course_listing team_assign user_assign].freeze

  attr_accessor :term, :tags, :context, :team, :user

  validates :role,
            inclusion: { in: VALID_CONTEXTS,
                         message: I18n.t('invalid_search') }

  VALID_CONTEXTS.map(&:to_s).each do |context|
    define_method "#{context}?" do
      self.context == context
    end
  end

  def initialize(term: '', tags: [], context: nil, options: {})
    @term = term
    @tags = tags
    @context = context

    case @context
    when 'team_assign' then @team = options[:team]
    when 'user_assign' then @user = options[:user]
    end
  end
end
