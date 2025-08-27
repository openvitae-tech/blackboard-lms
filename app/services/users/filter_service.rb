# frozen_string_literal: true

module Users
  class FilterService
    attr_accessor :team_id, :term

    def initialize(search_params)
      @team_id = search_params[:team_id]
      @term = search_params[:term]
    end

    def filter
      scope = User.where(team_id: @team_id) if @team_id.present?
      filter_by_matching_term(scope)
    end

    private

    def filter_by_matching_term(scope)
      return scope if term.blank?

      scope.where('name ILIKE ?', "%#{term}%")
    end
  end
end
