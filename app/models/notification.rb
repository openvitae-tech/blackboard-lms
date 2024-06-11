class Notification < ApplicationRecord
  include NotificationConcerns

  VALID_TYPES = %w(info)

  validates :ntype, inclusion: { in: VALID_TYPES , message: "%{value} is not a valid notification type" }
  validates :text, presence: true, length: { in: 2..1024 }

  belongs_to :user
end
