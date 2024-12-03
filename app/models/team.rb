# frozen_string_literal: true

class Team < ApplicationRecord
  include CustomValidations

  validates :name, presence: true

  has_one_attached :banner

  belongs_to :learning_partner
  has_many :users

  belongs_to :parent_team, class_name: 'Team', optional: true
  has_many :sub_teams, class_name: 'Team', foreign_key: 'parent_team_id'

  def members
    users
  end

  def ancestors
    return @ancestors if @ancestors.present?

    @ancestors = []
    temp = self

    while temp
      @ancestors.push(temp)
      temp = temp.parent_team
    end

    @ancestors
  end

  def parent_team?
    parent_team_id.blank?
  end

  def score
    return @score if @score.present?

    member_score = members.map(&:score).sum
    sub_team_score = sub_teams.map(&:score).sum
    @score = member_score + sub_team_score
  end
end
