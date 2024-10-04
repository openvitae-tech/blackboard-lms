# frozen_string_literal: true

class LearningPartner < ApplicationRecord
  include CustomValidations

  has_many :users, dependent: :destroy

  validates :name, presence: true, length: { in: 2..255 }
  validates :content, length: { maximum: 4096 }

  has_one_attached :logo
  has_one_attached :banner
  validate :acceptable_logo
  validate :acceptable_banner

  has_rich_text :content

  def parent_team
    @parent_team ||= Team.where(learning_partner_id: self.id, parent_team_id: nil).first
  end
end
