# frozen_string_literal: true

class Question < ApplicationRecord
  belongs_to :course

  paginates_per 5

  validates :content, presence: true
  validates :options, length: { minimum: 2, message: ->(_object, _data) { I18n.t('question.not_enough_options') } }
  validates :answers, length: { minimum: 1, message: ->(_object, _data) { I18n.t('question.not_answers') } }
  validate :validate_answers

  scope :verified, -> { where(is_verified: true) }
  scope :unverified, -> { where(is_verified: false) }

  def verify
    self.is_verified = true
    save
  end

  def unverify
    self.is_verified = false
    save
  end

  private

  def validate_answers
    return unless options.present? && answers.present?
    return if answers.to_set.subset?(options.to_set)

    errors.add(:answers, 'must be included in the list of options')
  end
end
