class ScormToken < ApplicationRecord

  validates :token, presence: true

  has_secure_token :token

  belongs_to :learning_partner
end
