# frozen_string_literal: true

class CourseCertificate < ApplicationRecord
  validates :issued_at, presence: true
  validates :certificate_id, presence: true, uniqueness: true
  validates :file_hash, presence: true, uniqueness: true

  has_one_attached :file

  belongs_to :course
  belongs_to :user
  belongs_to :certificate_template, optional: true
end
