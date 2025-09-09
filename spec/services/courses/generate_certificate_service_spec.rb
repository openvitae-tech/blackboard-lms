# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Courses::GenerateCertificateService do
  subject { described_class.instance }

  let(:learner) { create :user, :learner }
  let(:course) { create :course }
  let(:learning_partner) { create(:learning_partner) }
  let(:certificate_template) { create(:certificate_template, learning_partner:) }

  before do
    @fake_pdf = '%PDF-1.4 fake pdf content'
    grover_double = instance_double(Grover, to_pdf: @fake_pdf)
    allow(Grover).to receive(:new).and_return(grover_double)
  end

  describe '#generate' do
    it 'generates user course certificate' do
      expect do
        subject.generate(course, learner, certificate_template)
      end.to change(learner.course_certificates, :count).by(1)

      certificate = learner.course_certificates.find_by!(course:)

      expect(certificate.course).to eq(course)
      expect(certificate.user).to eq(learner)
      expect(certificate.certificate_template).to eq(certificate_template)
    end

    it 'sets file_hash correctly' do
      subject.generate(course, learner, certificate_template)
      certificate = learner.course_certificates.find_by!(course:)

      expect(certificate.file_hash).to eq(Digest::SHA256.hexdigest(@fake_pdf))
    end

    it 'attaches a pdf file' do
      subject.generate(course, learner, certificate_template)
      certificate = learner.course_certificates.find_by!(course:)

      expect(certificate.file).to be_attached
      expect(certificate.file.filename.to_s).to eq("certificate-#{course.title}-#{learner.name}.pdf")
    end
  end
end
