# frozen_string_literal: true

class CourseCertificate < ApplicationRecord
  validates :issued_at, presence: true
  validates :certificate_uuid, presence: true, uniqueness: true
  validates :file_hash, presence: true, uniqueness: true

  has_one_attached :file
  has_one_attached :certificate_thumbnail

  belongs_to :course
  belongs_to :user
end
