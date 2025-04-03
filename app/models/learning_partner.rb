# frozen_string_literal: true

class LearningPartner < ApplicationRecord
  include CustomValidations
  include PartnerState

  has_many :users, dependent: :destroy
  has_one :scorm, dependent: :destroy
  has_one :payment_plan, dependent: :destroy

  validates :name, presence: true, length: { in: 2..255 }
  validates :active_users_count, presence: true
  validates :content, length: { maximum: 4096 }

  has_one_attached :logo
  has_one_attached :banner
  validate :acceptable_logo
  validate :acceptable_banner

  has_rich_text :content

  def parent_team
    @parent_team ||= Team.where(learning_partner_id: id, parent_team_id: nil).first
  end
end
