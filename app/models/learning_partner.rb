class LearningPartner < ApplicationRecord

  has_many :users, dependent: :destroy
end
