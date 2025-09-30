# frozen_string_literal: true

class CertificateTemplate < ApplicationRecord
  ALLOWED_VARIABLES = %w[CandidateName CourseName IssueDate].freeze

  validates :name, presence: true
  validates :html_content, presence: true
  validates :active, inclusion: { in: [true, false] }

  validate :only_one_active_template, if: :active?
  validate :must_have_exact_template_variables
  validate :validate_assets

  belongs_to :learning_partner
  has_many_attached :assets

  private

  def only_one_active_template
    return unless learning_partner.certificate_templates.where(active: true).where.not(id: id).exists?

    errors.add(:base, 'There can be only one active certificate template per learning partner')
  end

  def must_have_exact_template_variables
    found = html_content.to_s.scan(/%\{([^}]+)\}/).flatten.uniq

    missing = ALLOWED_VARIABLES - found
    extra   = found - ALLOWED_VARIABLES

    errors.add(:html_content, "is missing required variables: #{missing.join(', ')}") if missing.any?

    return unless extra.any?

    errors.add(:html_content, "contains invalid variables: #{extra.join(', ')}")
  end

  def validate_assets
    return unless assets.attached?

    assets.each do |asset|
      unless asset.content_type.in?(%w[image/png image/webp image/jpeg
                                       image/jpg])
        errors.add(:assets,
                   'must be a PNG, JPEG or webp')
      end

      errors.add(:assets, 'must be less than 5MB') if asset.byte_size > 5.megabytes
    end
  end
end
