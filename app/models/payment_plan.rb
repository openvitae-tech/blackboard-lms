# frozen_string_literal: true

class PaymentPlan < ApplicationRecord
  DEFAULT_TOTAL_SEATS = 50
  DEFAULT_PER_SEAT_COST = 500

  validates :start_date, :end_date, :per_seat_cost, presence: true
  validates :total_seats, presence: true, numericality: { only_integer: true, greater_than: 0 }

  validate :acceptable_total_seats_count, if: -> { total_seats.present? }
  validate :validate_end_date

  after_initialize :assign_defaults

  belongs_to :learning_partner

  def self.default_plan
    new(start_date: Time.zone.today, end_date: Time.zone.today + 1.month)
  end

  def start_date
    self[:start_date]&.to_date
  end

  def end_date
    self[:end_date]&.to_date
  end

  private

  def assign_defaults
    self.total_seats ||= DEFAULT_TOTAL_SEATS
  end

  def acceptable_total_seats_count
    active_users_count = learning_partner.active_users_count

    return unless total_seats < active_users_count

    errors.add(:total_seats,
               I18n.t('learning_partner.payment_plan.total_seats_less_than_users', count: active_users_count))
  end

  def validate_end_date
    return if start_date.blank? || end_date.blank?

    errors.add(:end_date, I18n.t('learning_partner.payment_plan.end_date_must_be_greater')) if end_date <= start_date
  end
end
