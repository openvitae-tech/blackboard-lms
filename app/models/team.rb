# frozen_string_literal: true

class Team < ApplicationRecord
  include CustomValidations

  validates :name, presence: true
  validates :department, presence: true, allow_nil: true

  has_one_attached :banner

  belongs_to :learning_partner
  has_many :users # rubocop:disable Rails/HasManyOrHasOneDependent

  belongs_to :parent_team, class_name: 'Team', optional: true
  has_many :sub_teams, class_name: 'Team', foreign_key: 'parent_team_id' # rubocop:disable Rails/HasManyOrHasOneDependent,Rails/InverseOf

  has_many :team_enrollments, dependent: :destroy
  has_many :courses, through: :team_enrollments
  has_many :reports, dependent: :nullify

  DEPARTMENTS = [
    'Front Office',
    'Housekeeping',
    'Food and Beverage',
    'Engineering / Maintenance',
    'Sales and Marketing',
    'Security Department',
    'Human Resources Department',
    'Finance and Accounting',
    'Purchasing / Procurement',
    'IT / Systems',
    'Spa and Wellness',
    'Recreation and Activities',
    'Legal/Compliance',
    'Administration',
    'NA'
  ].freeze

  def members
    users.where.not(role: 'support').skip_deactivated
  end

  def all_members
    users.where.not(role: 'support')
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

    member_score = members.includes(:enrollments).map(&:score).sum
    sub_team_score = sub_teams.map(&:score).sum
    @score = member_score + sub_team_score
  end

  def enrolled_for_course?(course)
    team_enrollments.exists?(course:)
  end

  def within_hierarchy?(user)
    user.team == self || ancestors.include?(user.team)
  end

  def team_hierarchy_ids
    [id] + sub_teams.flat_map(&:team_hierarchy_ids)
  end
end
