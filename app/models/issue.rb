# frozen_string_literal: true

class Issue < ApplicationRecord
  belongs_to :user
  belongs_to :question

  validates :description, presence: true, length: { minimum: 10 }
  validates :user_id, uniqueness: { scope: :question_id }
end
