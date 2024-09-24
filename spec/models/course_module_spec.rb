# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseModule, type: :model do
  describe '#duration' do
    it 'calculates the duration of a course' do
      course = course_with_associations
      course_module = course.course_modules.first
      expect(course_module.duration).to eq(60)
    end
  end

  describe 'lesson navigation' do
    before(:all) do
      course = course_with_associations(modules_count: 2, lessons_count: 3)
      @course_module = course.first_module
    end

    let(:course_module) { @course_module }

    describe '#first_lesson' do
      it 'returns the first lesson in a course_module' do
        expect(course_module.first_lesson).not_to be_nil
        expect(course_module.first_lesson.id).to eq(course_module.lessons_in_order.first)
      end
    end

    describe '#last_lesson' do
      it 'returns the last lesson in a course_module' do
        expect(course_module.last_lesson).not_to be_nil
        expect(course_module.last_lesson.id).to eq(course_module.lessons_in_order.last)
      end
    end

    describe '#next_lesson' do
      it 'returns the next lesson in a course_module after the given lesson' do
        current_lesson = course_module.first_lesson
        expect(course_module.next_lesson(current_lesson)).not_to be_nil
        index = course_module.lessons_in_order.find_index(current_lesson.id)
        expect(course_module.next_lesson(current_lesson).id).to eq(course_module.lessons_in_order[index + 1])
      end

      it 'returns nil if the the current lesson is last lesson' do
        current_lesson = course_module.last_lesson
        expect(course_module.next_lesson(current_lesson)).to be_nil
      end
    end

    describe '#prev_lesson' do
      it 'returns the previous lesson in a course_module before the given lesson' do
        current_lesson = course_module.last_lesson
        expect(course_module.prev_lesson(current_lesson)).not_to be_nil
        index = course_module.lessons_in_order.find_index(current_lesson.id)
        expect(course_module.prev_lesson(current_lesson).id).to eq(course_module.lessons_in_order[index - 1])
      end

      it 'returns nil if the the current lesson is first lesson' do
        current_lesson = course_module.first_lesson
        expect(course_module.prev_lesson(current_lesson)).to be_nil
      end
    end
  end

  describe 'Module navigation within a Course' do
    before(:all) do
      @course = course_with_associations(modules_count: 2, lessons_count: 3)
    end

    let(:course) { @course }

    describe '#next_module' do
      it 'returns the next module after the given module' do
        course_module = course.first_module
        next_module = course_module.next_module
        expect(next_module).not_to be_nil
        index = course.course_modules_in_order.find_index(course_module.id)
        expect(next_module.id).to eq(course.course_modules_in_order[index + 1])
      end

      it 'returns nil if there are no next module' do
        course_module = course.last_module
        next_module = course_module.next_module
        expect(next_module).to be_nil
      end
    end

    describe '#prev_module' do
      it 'returns the prev module before the given module' do
        course_module = course.last_module
        prev_module = course_module.prev_module
        expect(prev_module).not_to be_nil
        index = course.course_modules_in_order.find_index(course_module.id)
        expect(prev_module.id).to eq(course.course_modules_in_order[index - 1])
      end

      it 'returns nil if there are no prev module' do
        course_module = course.first_module
        prev_module = course_module.prev_module
        expect(prev_module).to be_nil
      end
    end
  end
end
