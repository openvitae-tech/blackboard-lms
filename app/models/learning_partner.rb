class LearningPartner < ApplicationRecord

  has_many :users, dependent: :destroy

  has_one_attached :logo
  has_one_attached :banner
  validate :acceptable_logo
  validate :acceptable_banner


  def acceptable_logo
    Rails.logger.info "Validating logo"
    return unless logo.attached?

    unless logo.blob.byte_size <= 1.megabyte
      errors.add(:logo, "is too big")
    end
  end

  def acceptable_banner
    Rails.logger.info "Validating banner"
    return unless banner.attached?

    unless banner.blob.byte_size <= 1.megabyte
      errors.add(:banner, "is too big")
    end
  end
end
