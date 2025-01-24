# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scorm::Lesson do
  let(:course) { create :course }
  let(:course_module) { create :course_module, course: }
  let(:lesson) { create :lesson, course_module: }

  let(:scorm_lesson) { described_class.new(lesson) }

  describe '#title' do
    it 'returns the title of the lesson' do
      expect(lesson.title).to eq(scorm_lesson.title)
    end
  end

  describe '#videos' do
    before do
      create :local_content, lang: LocalContent::SUPPORTED_LANGUAGES[:hindi], lesson:
    end

    it 'returns the local contents of the lesson' do
      lesson.reload
      lesson_ids = scorm_lesson.videos.pluck(:id)
      expect(lesson.local_contents.pluck(:id).sort).to eq(lesson_ids.sort)
    end
  end
end
