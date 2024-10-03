# frozen_string_literal: true

class Team < ApplicationRecord
  include CustomValidations

  has_one_attached :banner

  belongs_to :learning_partner
  has_many :users

  belongs_to :parent_team, class_name: 'Team', optional: true
  has_many :sub_teams, class_name: 'Team', foreign_key: 'parent_team_id'

  def members
    users
  end

  def team_hierarchy
    return @team_hierarchy if @team_hierarchy.present?

    @team_hierarchy = []
    temp = self

    while temp
      @team_hierarchy.push(temp)
      temp = temp.parent_team
    end

    @team_hierarchy
  end
end
