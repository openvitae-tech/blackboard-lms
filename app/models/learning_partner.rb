class LearningPartner < ApplicationRecord
  include CustomValidations

  has_many :users, dependent: :destroy

  has_one_attached :logo
  has_one_attached :banner
  validate :acceptable_logo
  validate :acceptable_banner
end
