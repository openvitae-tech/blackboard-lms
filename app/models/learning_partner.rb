# frozen_string_literal: true

class LearningPartner < ApplicationRecord
  MAX_USER_COUNT = 50

  include CustomValidations

  has_many :users, dependent: :destroy

  validates :name, presence: true, length: { in: 2..255 }
  validates :content, length: { maximum: 4096 }
  validates :max_user_count, numericality: { only_integer: true, greater_than: 0 }
  validate :acceptable_max_user_count

  has_one_attached :logo
  has_one_attached :banner
  validate :acceptable_logo
  validate :acceptable_banner
  validate :acceptable_max_user_count
  after_initialize :assign_defaults

  has_rich_text :content

  def parent_team
    @parent_team ||= Team.where(learning_partner_id: self.id, parent_team_id: nil).first
  end

  def assign_defaults
    self.max_user_count ||= MAX_USER_COUNT
  end

  private

  def acceptable_max_user_count
    if self.max_user_count < self.users_count
      errors.add(:max_user_count, "cannot be less than actual number of active users (#{self.users_count}).")
    end
  end
end
