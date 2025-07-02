# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lesson, type: :model do
  let(:lesson) { create :lesson }

  describe '#title' do
    it 'is not valid without title' do
      lesson.title = ''
      expect(lesson).not_to be_valid
      expect(lesson.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                   field: 'Title'))
    end
  end

  describe '#duration' do
    it 'is not valid without duration' do
      lesson.duration = nil
      expect(lesson).not_to be_valid
      expect(lesson.errors.full_messages.to_sentence).to include('Duration for the video is not set')
    end
  end

  describe '#course_module' do
    it 'is not valid without course module' do
      lesson.course_module = nil
      expect(lesson).not_to be_valid
      expect(lesson.errors.full_messages.to_sentence).to include(t('must_exist',
                                                                   entity: 'Course module'))
    end
  end

  describe '#unique_local_content_lang' do
    before do
      lesson.local_contents.build(lang: LocalContent::SUPPORTED_LANGUAGES[:english])
      lesson.local_contents.build(lang: LocalContent::SUPPORTED_LANGUAGES[:english])
    end

    it 'raises error for duplicate languages' do
      expect(lesson).not_to be_valid
      expect(lesson.errors.full_messages.to_sentence).to include(t('lesson.duplicate_lesson',
                                                                   langs: 'English'))
    end
  end

  describe '#has_local_contents' do
    it 'does not create lesson without local content' do
      course_module = create :course_module
      new_lesson = described_class.new(title: 'Body language', course_module:)
      new_lesson.save
      expect(new_lesson).not_to be_valid
      expect(new_lesson.errors.full_messages.to_sentence).to include(t('lesson.must_have_local_content'))
    end
  end

  describe 'Updates the course duration when duration is updated' do
    it 'trigger after_save callback to update the course duration' do
      course_module = create :course_module
      course = course_module.course
      old_duration = course.reload.duration
      new_lesson = described_class.new(title: 'Body language', course_module:, duration: 10)
      new_lesson.local_contents.push(build(:local_content))
      new_lesson.save
      expect(course.reload.duration - old_duration).to eq(10)

      # updates the object
      old_duration = course.duration
      new_lesson.duration = new_lesson.duration + 20
      new_lesson.save
      expect(course.reload.duration - old_duration).to eq(20)
    end
  end
end
