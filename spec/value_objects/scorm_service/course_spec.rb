# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScormService::Course do
  let(:learning_partner) { create :learning_partner }
  let(:scorm) { create :scorm, learning_partner: }
  let(:course) { create :course }
  let(:scorm_course) { described_class.new(course, scorm.token) }

  describe '#title' do
    it 'returns the title of the course' do
      expect(course.title).to eq(scorm_course.title)
    end
  end

  describe '#description' do
    it 'returns the description of the course' do
      expect(course.description).to eq(scorm_course.description)
    end
  end

  describe '#course_modules' do
    before do
      create_list :course_module, 3, course:
    end

    it 'returns the course modules of the course' do
      module_ids = course.course_modules.map(&:id)
      expect(course.course_modules.pluck(:id).sort).to eq(module_ids.sort)
    end
  end
end
