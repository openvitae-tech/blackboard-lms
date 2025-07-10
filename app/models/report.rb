# frozen_string_literal: true

class Report < ApplicationRecord
  TEAM_REPORT = 'team_report'

  has_one_attached :document

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :report_type, inclusion: { in: [TEAM_REPORT], message: I18n.t('reports.invalid_report_type') }

  validate :start_date_before_end_date

  belongs_to :team, optional: true
  belongs_to :generator,
             class_name: 'User',
             foreign_key: :generated_by,
             inverse_of: :reports,
             optional: true

  def start_date_before_end_date
    return if start_date.nil? || end_date.nil?
    return if start_date < end_date

    errors.add(:start_date, 'Start date must be less than end date')
  end
end
