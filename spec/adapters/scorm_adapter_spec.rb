# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScormAdapter do
  let(:course) { create :course }
  let(:learning_partner) { create :learning_partner }
  let(:scorm) { create :scorm, learning_partner: }

  describe '#process' do
    it 'returns course object' do
      scorm_adaptor_service = described_class.new(course, scorm.token).process
      expect(course.id).to eq(scorm_adaptor_service.course.id)
    end
  end
end
