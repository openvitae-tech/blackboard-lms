# frozen_string_literal: true

class SearchContext
  include ActiveModel::API

  # Search contexts, ie, from where the search is initiated
  HOME_PAGE = :home_page
  COURSE_LISTING = :course_listing
  TEAM_ASSIGN = :team_assign
  USER_ASSIGN = :user_assign
  VALID_CONTEXTS = [HOME_PAGE, COURSE_LISTING, TEAM_ASSIGN, USER_ASSIGN].freeze

  # Search scopes
  ANY = :all
  ENROLLED = :enrolled
  UNENROLLED = :unenrolled
  VALID_TYPES = [ANY, ENROLLED, UNENROLLED].freeze

  attr_reader :term, :tags, :context, :team, :user, :type

  validates :context,
            inclusion: { in: VALID_CONTEXTS,
                         message: I18n.t('invalid_search_context') }
  validates :type, inclusion: { in: VALID_TYPES,
                                message: I18n.t('invalid_search_type') }

  VALID_CONTEXTS.each do |context_value|
    define_method "#{context_value}?" do
      context == context_value
    end
  end

  def initialize(context:, term: '', tags: [], type: nil, options: {})
    @term = sanitize_parameter(term, '')
    @tags = sanitize_parameter(tags, [])
    @context = sanitize_parameter(context)&.to_sym
    @type = sanitize_parameter(type, ANY).to_sym

    case context
    when TEAM_ASSIGN
      @team = options[:team]
      raise Errors::IllegalSearchContext, "Team can't be blank in context `team_assign`" if team.nil?
    when USER_ASSIGN
      @user = options[:user]
      raise Errors::IllegalSearchContext, "User can't be blank in context `user_assign`" if user.nil?
    end

    raise Errors::IllegalSearchContext, errors.full_messages.join('\n') unless valid?
  end

  def search_enrolled_courses?
    type == ENROLLED
  end

  def search_unenrolled_courses?
    type == UNENROLLED
  end

  def search_all_courses?
    type == ANY
  end

  def to_course_path
    "#{Rails.application.routes.url_helpers.courses_path}?#{to_query_str}"
  end

  def to_search_path
    "#{Rails.application.routes.url_helpers.searches_path}?#{to_query_str}"
  end

  def to_query_str
    {
      term: @term,
      tags: @tags,
      context: @context,
      type: @type
    }.filter { |_k, v| !v.empty? }.to_query
  end

  private

  def sanitize_parameter(param, default = nil)
    return default if param.nil?

    if param.instance_of?(String)
      param.strip
    elsif param.instance_of?(Array)
      param.compact!
      param.map(&:strip).filter { |t| !t.empty? }.uniq
    else
      param
    end
  end
end
