class Scorm < ApplicationRecord

  validates :token, presence: true, uniqueness: true

  has_secure_token :token

  belongs_to :learning_partner

  def regenerate_scorm_token
    regenerate_token
  end
end
