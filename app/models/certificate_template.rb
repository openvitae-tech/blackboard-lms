# frozen_string_literal: true

class CertificateTemplate < ApplicationRecord
  validates :name, :html_content, presence: true

  validate :only_one_active_template, if: :active?

  belongs_to :learning_partner

  private

  def only_one_active_template
    return unless learning_partner.certificate_templates.where(active: true).where.not(id: id).exists?

    errors.add(:active, 'There can be only one active certificate template per learning partner')
  end
end
