# frozen_string_literal: true

class SearchContext
  include ActiveModel::API

  # from where the search/filter action is initiated
  VALID_CONTEXTS = %i(home course team_assign user_assign)

  attr_accessor :term, :tags, :context, :team, :user

  validates :role,
    inclusion: { in: VALID_CONTEXTS,
                 message: '%<value>s is not a valid search context' }

  VALID_CONTEXTS.map(&:to_s).each do |context|
    define_method "#{context}?" do
      self.context == context
    end
  end

  def initialize(search_params)
    @term = search_params.fetch(:term, "")
    @tags = search_params.fetch(:tags, [])
    @context = search_params[:context]

    case @context
    when 'team_assign' then @team = search_params[:team]
    when 'user_assign' then @user = search_params[:user]
    else
      # type code here
    end
  end
end