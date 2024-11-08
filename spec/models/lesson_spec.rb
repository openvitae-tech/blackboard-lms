# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lesson, type: :model do
  let(:lesson) { create :lesson }

  describe '#title' do
    it 'should not be valid without title' do
      lesson.title = ''
      expect(lesson).not_to be_valid
      expect(lesson.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                   field: 'Title'))
    end
  end

  describe '#course_module' do
    it 'should not be valid without course module' do
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
    it 'should raise error for duplicate languages' do
      expect(lesson).not_to be_valid
      expect(lesson.errors.full_messages.to_sentence).to include(t('lesson.duplicate_lesson',
                                                                   langs: 'English'))
    end
  end

  describe '#has_local_contents' do
    it 'should not create lesson without local content' do
      course_module = create :course_module
      new_lesson = Lesson.new(title: 'Body language', course_module:)
      new_lesson.save
      expect(new_lesson).not_to be_valid
      expect(new_lesson.errors.full_messages.to_sentence).to include(t('lesson.must_have_local_content'))
    end
  end
end
