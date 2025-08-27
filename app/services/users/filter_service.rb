# frozen_string_literal: true

module Users
  class FilterService
    attr_accessor :team, :term

    def initialize(team, term: '', all_members: false)
      # all_members = true include deactivated members in results
      @all_members = all_members
      @team = team
      @term = term
    end

    def filter
      scope = @all_members ? @team.all_members : @team.members
      filter_by_matching_term(scope)
    end

    private

    def filter_by_matching_term(scope)
      return scope if term.blank?

      scope.where('name ILIKE ?', "%#{term}%")
    end
  end
end
