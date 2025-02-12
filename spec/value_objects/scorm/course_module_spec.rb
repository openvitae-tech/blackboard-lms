# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scorm::CourseModule do
  let(:course) { create :course }
  let(:course_module) { create :course_module, course: }

  let(:scorm_course_module) { described_class.new(course_module) }

  describe '#title' do
    it 'returns the title of the course module' do
      expect(course_module.title).to eq(scorm_course_module.title)
    end
  end

  describe '#lessons' do
    before do
      create_list :lesson, 3, course_module:
    end

    it 'returns the lessons of the course module' do
      lesson_ids = course_module.lessons.map(&:id)
      expect(course_module.lessons.pluck(:id).sort).to eq(lesson_ids.sort)
    end
  end
end
