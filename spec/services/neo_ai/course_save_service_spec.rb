# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NeoAi::CourseSaveService do
  let(:neo_ai) { instance_double(NeoAi::Client) }
  let(:service) { described_class.new(neo_ai) }
  let(:neo_ai_data) do
    {
      'title' => 'Test Course Title',
      'description' => 'An AI generated course about a very interesting topic for learners',
      'modules' => [
        {
          'id' => 'm1',
          'title' => 'Module One',
          'lessons' => [
            {
              'id' => 'l1',
              'title' => 'Lesson One',
              'description' => 'Introduction to the topic',
              'estimated_duration' => 90,
              'video_url' => 'https://neo.ai/video.mp4'
            }
          ]
        }
      ]
    }
  end

  before do
    allow(neo_ai).to receive(:find_course).with('neo-c1').and_return(neo_ai_data)
  end

  describe '#call' do
    it 'creates a course with correct attributes' do
      course = service.call('neo-c1')
      expect(course.title).to eq('Test Course Title')
      expect(course.neo_ai_course_id).to eq('neo-c1')
      expect(course.visibility).to eq('private')
    end

    it 'creates modules with correct ordering' do
      course = service.call('neo-c1')
      expect(course.course_modules.count).to eq(1)
      expect(course.course_modules_in_order).to eq([course.course_modules.first.id])
    end

    it 'creates lessons with duration and video source' do
      course = service.call('neo-c1')
      lesson = course.course_modules.first.lessons.first
      expect(lesson.title).to eq('Lesson One')
      expect(lesson.duration).to eq(90)
      expect(lesson.video_streaming_source).to eq('https://neo.ai/video.mp4')
    end

    it 'sets lessons_in_order on the module' do
      course = service.call('neo-c1')
      mod = course.course_modules.first
      expect(mod.lessons_in_order).to eq([mod.lessons.first.id])
    end

    it 'is idempotent - returns the existing course without duplicating' do
      first = service.call('neo-c1')
      expect { service.call('neo-c1') }.not_to change(Course, :count)
      expect(service.call('neo-c1').id).to eq(first.id)
    end

    it 'does not call neo_ai again when the course is already saved' do
      service.call('neo-c1')
      service.call('neo-c1')
      expect(neo_ai).to have_received(:find_course).once
    end
  end
end
