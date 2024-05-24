class LearningPartner < ApplicationRecord
  include CustomValidations

  has_many :users, dependent: :destroy

  validates :name, presence: true, length: { in: 2..255 }
  validates :about, length: { maximum: 1024 }

  has_one_attached :logo
  has_one_attached :banner
  validate :acceptable_logo
  validate :acceptable_banner
end
