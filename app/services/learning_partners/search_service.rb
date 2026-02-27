# frozen_string_literal: true

module LearningPartners
  class SearchService
    attr_reader :query

    def initialize(query)
      @query = query
    end

    def search
      scope = LearningPartner.includes(%i[logo_attachment payment_plan]).order(:name)
      return scope if query.blank?

      scope.where('name ILIKE ?', "#{LearningPartner.sanitize_sql_like(query)}%")
    end
  end
end
