class Scorm < ApplicationRecord

  validates :token, presence: true, uniqueness: true

  has_secure_token :token

  before_create :set_expires_at

  belongs_to :learning_partner

  def regenerate_scorm_token
    regenerate_token
  end

  private

  def set_expires_at
    self.expires_at = 3.months.from_now
  end
end
